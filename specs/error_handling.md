# Project Chimera - Error Handling & Resilience Specification

**Document**: `specs/error_handling.md`  
**Version**: 1.0.0  
**Last Updated**: February 6, 2026  
**Dependencies**: [_meta.md](specs/_meta.md), [technical.md](specs/technical.md), [security.md](specs/security.md), [functional.md](specs/functional.md)

## Overview

This specification defines comprehensive error handling, resilience patterns, and recovery mechanisms for Project Chimera's autonomous agent fleet. The system must maintain **99.9% uptime** while safely handling failures across economic transactions, content generation, external API integrations, and inter-agent communication.

**Core Principle**: **"Fail Safe, Fail Visible, Fail Forward"**
- **Fail Safe**: Errors never compromise security or economic constraints
- **Fail Visible**: All failures logged and observable in real-time
- **Fail Forward**: Automatic recovery where possible, graceful degradation otherwise

---

## Error Classification Taxonomy

### 1. Transient Errors (Retry-able)

**Definition**: Temporary failures that may succeed on retry without changes to request parameters.

#### 1.1 Network & Communication Errors
```python
class TransientNetworkError(BaseException):
    """Network-level failures that are inherently temporary"""
    error_code = "ERR_NETWORK_TRANSIENT"
    retry_strategy = "exponential_backoff"
    max_retries = 3
    base_delay_ms = 100
```

**Examples**:
- `ConnectionTimeout`: Socket connection timeout (default 30s)
- `ReadTimeout`: Response read timeout (default 60s)
- `TemporaryDNSFailure`: DNS resolution temporarily unavailable
- `NetworkUnreachable`: Route to host temporarily down

**Retry Strategy**:
```python
# Exponential backoff with jitter
delays = [100ms, 200ms, 400ms] + random_jitter(0-50ms)
```

#### 1.2 Rate Limiting & Throttling
```python
class RateLimitError(BaseException):
    """External API rate limit exceeded"""
    error_code = "ERR_RATE_LIMIT"
    retry_strategy = "wait_for_reset"
    max_retries = 2
```

**Examples**:
- `TwitterAPIRateLimit`: 429 response with `x-rate-limit-reset` header
- `OpenAIRateLimit`: 429 with `retry-after` header
- `CoinbaseRateLimit`: 429 with exponential backoff recommendation

**Retry Strategy**:
```python
# Wait for rate limit reset + small buffer
if "retry-after" in response.headers:
    wait_seconds = int(response.headers["retry-after"]) + 5
elif "x-rate-limit-reset" in response.headers:
    reset_time = int(response.headers["x-rate-limit-reset"])
    wait_seconds = max(0, reset_time - time.time()) + 5
else:
    wait_seconds = 60  # Conservative fallback
```

#### 1.3 Temporary Service Unavailability
```python
class ServiceUnavailableError(BaseException):
    """Upstream service temporarily down (503, 504)"""
    error_code = "ERR_SERVICE_UNAVAILABLE"
    retry_strategy = "exponential_backoff_with_circuit_breaker"
    max_retries = 3
    circuit_breaker_threshold = 5  # Open circuit after 5 consecutive failures
```

**Examples**:
- `503 Service Unavailable`: Upstream service overloaded
- `504 Gateway Timeout`: Upstream service not responding
- `RedisConnectionError`: Redis temporarily unavailable
- `WeaviateHealthCheckFailed`: Vector DB in maintenance mode

**Retry Strategy**:
```python
# Exponential backoff with circuit breaker integration
delays = [1s, 2s, 4s]
if circuit_breaker.failure_count > threshold:
    circuit_breaker.open()  # Stop retries, return cached/degraded response
```

---

### 2. Permanent Errors (Non-Retry-able)

**Definition**: Errors caused by invalid input, authorization failures, or policy violations that will not succeed on retry without correcting the request.

#### 2.1 Authentication & Authorization Failures
```python
class AuthenticationError(BaseException):
    """Invalid or expired credentials"""
    error_code = "ERR_AUTH_FAILED"
    retry_strategy = "none"
    escalation = "immediate_hitl"
    severity = "critical"
```

**Examples**:
- `InvalidAPIKey`: API key not recognized or expired
- `ExpiredToken`: JWT or OAuth token expired (requires refresh)
- `InsufficientPermissions`: Valid credentials but missing required scope
- `WalletKeyInvalid`: Cryptographic wallet private key malformed

**Handling Strategy**:
```python
# No retries - log, alert, escalate to HITL
async def handle_auth_error(error: AuthenticationError):
    await log_security_event(error, severity="critical")
    await notify_ops_team(error)
    await escalate_to_hitl(
        reason="Authentication failure requires manual credential rotation",
        agent_id=error.agent_id,
        error_details=error.to_dict()
    )
    # Pause agent until credentials resolved
    await agent_registry.set_status(error.agent_id, "suspended")
```

#### 2.2 Budget & Economic Policy Violations
```python
class BudgetExceededError(BaseException):
    """Transaction would violate economic security constraints"""
    error_code = "ERR_BUDGET_EXCEEDED"
    retry_strategy = "none"
    escalation = "cfo_judge_review"
    severity = "high"
```

**Examples**:
- `DailyLimitExceeded`: Would exceed $50/day limit (see [security.md](specs/security.md#L33))
- `TransactionLimitExceeded`: Single transaction >$20 (see [security.md](specs/security.md#L47))
- `InsufficientBalance`: Wallet balance insufficient for requested transaction
- `UnauthorizedRecipient`: Transaction recipient not on allowlist

**Handling Strategy**:
```python
# CFO Judge Agent reviews for potential exception
async def handle_budget_error(error: BudgetExceededError):
    await log_economic_event(error, category="budget_enforcement")
    
    # Check if CFO Judge can approve exception
    cfo_decision = await cfo_judge_agent.review_transaction(
        transaction=error.transaction_details,
        current_spend=error.current_daily_spend,
        justification=error.business_justification
    )
    
    if cfo_decision.approved:
        # Rare exception granted with heightened logging
        await log_audit_trail(f"CFO override approved: {cfo_decision.reason}")
        return await proceed_with_transaction()
    else:
        # Reject and escalate if strategically important
        if error.campaign_priority == "critical":
            await escalate_to_hitl(reason="Budget constraint blocking critical campaign")
        return TransactionRejectedResponse(reason=cfo_decision.reason)
```

#### 2.3 Content Policy Violations
```python
class ContentPolicyViolationError(BaseException):
    """Generated content violates platform or internal policies"""
    error_code = "ERR_CONTENT_VIOLATION"
    retry_strategy = "regenerate_with_stricter_constraints"
    escalation = "judge_agent_review"
    severity = "medium"
```

**Examples**:
- `PlatformContentBanned`: Content violates Twitter/TikTok community guidelines
- `InternalSafetyFilter`: Content fails internal toxicity checks
- `CopyrightRisk`: Content similarity to copyrighted material too high
- `BrandSafetyViolation`: Content misaligned with brand values

**Handling Strategy**:
```python
# Judge Agent reviews and decides regeneration vs escalation
async def handle_content_violation(error: ContentPolicyViolationError):
    judge_review = await judge_agent.review_content(
        content=error.generated_content,
        violation_reason=error.violation_type,
        persona=error.persona_id
    )
    
    if judge_review.can_regenerate:
        # Attempt regeneration with stricter safety constraints
        return await regenerate_content(
            original_prompt=error.prompt,
            safety_level="strict",
            exclude_patterns=judge_review.flagged_patterns
        )
    else:
        # Violation too severe - require HITL review
        await escalate_to_hitl(
            reason=f"Content generation repeated policy violation: {error.violation_type}",
            content_sample=error.redacted_sample
        )
```

#### 2.4 Invalid Input & Validation Errors
```python
class ValidationError(BaseException):
    """Request payload fails schema validation"""
    error_code = "ERR_VALIDATION_FAILED"
    retry_strategy = "none"
    escalation = "log_and_reject"
    severity = "low"
```

**Examples**:
- `InvalidTaskSchema`: Task payload doesn't match ChimeraTask schema
- `MissingRequiredField`: Required field (e.g., `persona_id`) not provided
- `InvalidEnumValue`: Field contains value not in allowed enum
- `TypeMismatch`: Field type doesn't match schema (e.g., string instead of UUID)

**Handling Strategy**:
```python
# Log validation errors for debugging, reject request immediately
async def handle_validation_error(error: ValidationError):
    await log_validation_failure(
        schema=error.schema_name,
        violations=error.validation_errors,
        payload_sample=error.redacted_payload
    )
    
    # Return detailed error to caller for debugging
    return ValidationErrorResponse(
        error_code="ERR_VALIDATION_FAILED",
        violations=[
            {"field": v.field, "error": v.message, "received": v.value}
            for v in error.validation_errors
        ]
    )
```

---

### 3. Critical Errors (Immediate HITL Escalation)

**Definition**: Errors indicating potential security breaches, data corruption, or systemic failures requiring immediate human intervention.

#### 3.1 Security & Integrity Violations
```python
class SecurityViolationError(BaseException):
    """Security boundary breach detected"""
    error_code = "ERR_SECURITY_BREACH"
    retry_strategy = "none"
    escalation = "immediate_hitl_and_pause_agent"
    severity = "critical"
    alert_channels = ["pagerduty", "slack_security", "email_ciso"]
```

**Examples**:
- `UnauthorizedCredentialAccess`: Attempt to access credentials outside authorized scope
- `EncryptionFailure`: Failure to encrypt sensitive data before storage
- `AuditLogTampering`: Modification detected in immutable audit logs
- `SuspiciousTransactionPattern`: Transaction pattern indicates potential compromise

**Handling Strategy**:
```python
# Immediate containment and human escalation
async def handle_security_violation(error: SecurityViolationError):
    # 1. Immediately suspend affected agent
    await agent_registry.emergency_suspend(
        agent_id=error.agent_id,
        reason="Security violation detected"
    )
    
    # 2. Fire multi-channel alerts
    await alert_manager.critical_alert(
        message=f"SECURITY VIOLATION: {error.violation_type}",
        agent_id=error.agent_id,
        channels=["pagerduty", "slack_security"]
    )
    
    # 3. Preserve forensic evidence
    await forensics.capture_state(
        agent_id=error.agent_id,
        memory_snapshot=True,
        transaction_history=True,
        credential_access_logs=True
    )
    
    # 4. Escalate to HITL with full context
    await escalate_to_hitl(
        priority="critical",
        reason=error.violation_type,
        evidence=error.forensic_data,
        recommended_action="Human review required before agent resumption"
    )
```

#### 3.2 Data Corruption & Consistency Errors
```python
class DataCorruptionError(BaseException):
    """Data integrity violation detected"""
    error_code = "ERR_DATA_CORRUPTION"
    retry_strategy = "none"
    escalation = "immediate_hitl_and_rollback"
    severity = "critical"
```

**Examples**:
- `MemoryInconsistency`: Redis and Weaviate memory state diverged
- `ChecksumMismatch`: Stored content checksum doesn't match expected value
- `ForeignKeyViolation`: PostgreSQL referential integrity constraint violated
- `DuplicatePrimaryKey`: Attempt to insert duplicate UUID (indicates system clock issues or logic bug)

**Handling Strategy**:
```python
# Rollback transaction, preserve state, escalate for investigation
async def handle_data_corruption(error: DataCorruptionError):
    # 1. Rollback any in-progress transactions
    if error.active_transaction:
        await db.rollback_transaction(error.transaction_id)
    
    # 2. Preserve corrupted state for analysis
    await forensics.snapshot_database_state(
        tables_affected=error.affected_tables,
        preserve_duration="7_days"
    )
    
    # 3. Attempt automatic recovery if safe
    if error.has_backup and error.corruption_scope == "single_record":
        recovery_result = await attempt_recovery_from_backup(error)
        if recovery_result.success:
            await log_recovery_attempt(result=recovery_result)
            return
    
    # 4. Escalate to HITL for manual investigation
    await escalate_to_hitl(
        priority="critical",
        reason="Data corruption requires manual investigation and repair",
        affected_systems=error.affected_systems,
        data_snapshot_id=error.forensic_snapshot_id
    )
```

#### 3.3 Economic Anomalies
```python
class EconomicAnomalyError(BaseException):
    """Unusual spending pattern indicating potential issue"""
    error_code = "ERR_ECONOMIC_ANOMALY"
    retry_strategy = "none"
    escalation = "immediate_hitl"
    severity = "critical"
```

**Examples**:
- `RapidSpendingSpike`: 5x increase in spending rate within 10 minutes
- `UnexpectedRecipient`: Transaction to wallet address never used before
- `OffHoursActivity`: Economic activity during configured inactive hours
- `RepeatedFailedTransactions`: 10+ failed transaction attempts in short window

**Handling Strategy**:
```python
# Freeze economic activity, escalate for human review
async def handle_economic_anomaly(error: EconomicAnomalyError):
    # 1. Immediately freeze all economic transactions for this agent
    await economic_controls.freeze_transactions(
        agent_id=error.agent_id,
        reason="Anomaly detection triggered",
        duration="pending_human_review"
    )
    
    # 2. Generate anomaly analysis report
    analysis = await anomaly_detector.generate_report(
        agent_id=error.agent_id,
        anomaly_type=error.anomaly_pattern,
        historical_baseline=error.baseline_data,
        current_behavior=error.anomalous_behavior
    )
    
    # 3. Escalate to HITL with full context
    await escalate_to_hitl(
        priority="high",
        reason=f"Economic anomaly detected: {error.anomaly_pattern}",
        analysis_report=analysis,
        recommended_action="Review transaction history and approve resumption or investigate further"
    )
```

---

## Retry Strategies & Backoff Algorithms

### Exponential Backoff with Jitter

**Implementation**:
```python
import random
from typing import Callable, TypeVar, Optional

T = TypeVar('T')

async def retry_with_exponential_backoff(
    func: Callable[..., T],
    max_retries: int = 3,
    base_delay_ms: int = 100,
    max_delay_ms: int = 10000,
    jitter_range_ms: int = 50,
    retry_on_exceptions: tuple = (TransientNetworkError, ServiceUnavailableError)
) -> T:
    """
    Retry function with exponential backoff and jitter.
    
    Args:
        func: Async function to retry
        max_retries: Maximum number of retry attempts
        base_delay_ms: Initial delay in milliseconds
        max_delay_ms: Maximum delay cap
        jitter_range_ms: Random jitter range (0 to jitter_range_ms)
        retry_on_exceptions: Tuple of exception types to retry on
    
    Returns:
        Result of successful function call
    
    Raises:
        Last exception if all retries exhausted
    """
    last_exception = None
    
    for attempt in range(max_retries + 1):
        try:
            result = await func()
            
            # Log successful retry if not first attempt
            if attempt > 0:
                await log_retry_success(
                    function=func.__name__,
                    attempts=attempt + 1
                )
            
            return result
            
        except retry_on_exceptions as e:
            last_exception = e
            
            # Don't retry on last attempt
            if attempt == max_retries:
                break
            
            # Calculate backoff delay: 2^attempt * base_delay + jitter
            delay_ms = min(
                (2 ** attempt) * base_delay_ms + random.randint(0, jitter_range_ms),
                max_delay_ms
            )
            
            await log_retry_attempt(
                function=func.__name__,
                attempt=attempt + 1,
                max_retries=max_retries,
                delay_ms=delay_ms,
                exception=str(e)
            )
            
            await asyncio.sleep(delay_ms / 1000.0)
    
    # All retries exhausted - escalate
    await log_retry_exhausted(
        function=func.__name__,
        attempts=max_retries + 1,
        final_exception=last_exception
    )
    
    raise last_exception
```

### Rate Limit Aware Retry

**Implementation**:
```python
async def retry_with_rate_limit_handling(
    func: Callable[..., T],
    max_retries: int = 2
) -> T:
    """
    Retry function respecting rate limit headers from API responses.
    """
    for attempt in range(max_retries + 1):
        try:
            result = await func()
            return result
            
        except RateLimitError as e:
            if attempt == max_retries:
                raise
            
            # Extract wait time from response headers
            if e.retry_after_seconds:
                wait_time = e.retry_after_seconds + 5  # Add 5s buffer
            elif e.rate_limit_reset_timestamp:
                wait_time = max(0, e.rate_limit_reset_timestamp - time.time()) + 5
            else:
                wait_time = 60  # Conservative fallback
            
            await log_rate_limit_wait(
                function=func.__name__,
                wait_seconds=wait_time,
                attempt=attempt + 1
            )
            
            await asyncio.sleep(wait_time)
    
    raise RateLimitError("Rate limit retry exhausted")
```

---

## Circuit Breaker Pattern

### Circuit Breaker State Machine

```
┌─────────────┐
│   CLOSED    │ ◄─────────────────────────┐
│ (Normal)    │                            │
└──────┬──────┘                            │
       │ Failure Count                     │
       │ > Threshold                       │
       ▼                                   │
┌─────────────┐      Timeout              │
│    OPEN     │────────────►┌─────────────┤
│ (Blocking)  │             │  HALF-OPEN  │
│             │             │ (Testing)   │
└─────────────┘             └─────────────┘
                                   │
                   Success ────────┘
                   Failure loops back to OPEN
```

### Implementation

**Redis-Based Circuit Breaker**:
```python
from enum import Enum
from datetime import datetime, timedelta

class CircuitState(str, Enum):
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Blocking requests
    HALF_OPEN = "half_open"  # Testing recovery

class CircuitBreaker:
    """
    Circuit breaker for external service dependencies.
    State stored in Redis for fleet-wide coordination.
    """
    
    def __init__(
        self,
        service_name: str,
        failure_threshold: int = 5,
        recovery_timeout_seconds: int = 60,
        half_open_max_calls: int = 3
    ):
        self.service_name = service_name
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout_seconds
        self.half_open_max_calls = half_open_max_calls
        self.redis_key = f"circuit_breaker:{service_name}"
    
    async def call(self, func: Callable) -> any:
        """
        Execute function through circuit breaker.
        """
        state = await self._get_state()
        
        if state == CircuitState.OPEN:
            # Check if timeout elapsed
            if await self._should_attempt_reset():
                await self._transition_to_half_open()
            else:
                raise CircuitOpenError(
                    f"Circuit breaker OPEN for {self.service_name}. "
                    f"Service unavailable."
                )
        
        if state == CircuitState.HALF_OPEN:
            # Limit calls in half-open state
            if await self._half_open_call_count() >= self.half_open_max_calls:
                raise CircuitOpenError(
                    f"Circuit breaker HALF_OPEN call limit reached for {self.service_name}"
                )
        
        try:
            # Attempt call
            result = await func()
            
            # Success - potentially reset circuit
            if state == CircuitState.HALF_OPEN:
                await self._transition_to_closed()
                await log_circuit_breaker_event(
                    service=self.service_name,
                    event="recovery_success",
                    state="closed"
                )
            else:
                await self._record_success()
            
            return result
            
        except Exception as e:
            # Failure - increment failure count
            await self._record_failure()
            
            failure_count = await self._get_failure_count()
            
            if failure_count >= self.failure_threshold:
                await self._transition_to_open()
                await log_circuit_breaker_event(
                    service=self.service_name,
                    event="circuit_opened",
                    failure_count=failure_count,
                    threshold=self.failure_threshold
                )
            
            raise
    
    async def _get_state(self) -> CircuitState:
        state_str = await redis.get(f"{self.redis_key}:state")
        return CircuitState(state_str) if state_str else CircuitState.CLOSED
    
    async def _get_failure_count(self) -> int:
        count = await redis.get(f"{self.redis_key}:failures")
        return int(count) if count else 0
    
    async def _record_success(self):
        await redis.set(f"{self.redis_key}:failures", 0)
        await redis.set(f"{self.redis_key}:last_success", datetime.utcnow().isoformat())
    
    async def _record_failure(self):
        pipe = redis.pipeline()
        pipe.incr(f"{self.redis_key}:failures")
        pipe.set(f"{self.redis_key}:last_failure", datetime.utcnow().isoformat())
        await pipe.execute()
    
    async def _transition_to_open(self):
        pipe = redis.pipeline()
        pipe.set(f"{self.redis_key}:state", CircuitState.OPEN)
        pipe.set(f"{self.redis_key}:opened_at", datetime.utcnow().isoformat())
        await pipe.execute()
    
    async def _transition_to_half_open(self):
        pipe = redis.pipeline()
        pipe.set(f"{self.redis_key}:state", CircuitState.HALF_OPEN)
        pipe.set(f"{self.redis_key}:half_open_calls", 0)
        await pipe.execute()
    
    async def _transition_to_closed(self):
        pipe = redis.pipeline()
        pipe.set(f"{self.redis_key}:state", CircuitState.CLOSED)
        pipe.set(f"{self.redis_key}:failures", 0)
        pipe.delete(f"{self.redis_key}:opened_at")
        pipe.delete(f"{self.redis_key}:half_open_calls")
        await pipe.execute()
    
    async def _should_attempt_reset(self) -> bool:
        opened_at_str = await redis.get(f"{self.redis_key}:opened_at")
        if not opened_at_str:
            return True
        
        opened_at = datetime.fromisoformat(opened_at_str)
        elapsed = (datetime.utcnow() - opened_at).total_seconds()
        return elapsed >= self.recovery_timeout
    
    async def _half_open_call_count(self) -> int:
        count = await redis.incr(f"{self.redis_key}:half_open_calls")
        return count
```

### Circuit Breaker Configuration by Service

```python
# Circuit breaker thresholds for external services
CIRCUIT_BREAKER_CONFIG = {
    "twitter_api": {
        "failure_threshold": 5,
        "recovery_timeout_seconds": 120,
        "half_open_max_calls": 3
    },
    "openai_api": {
        "failure_threshold": 3,
        "recovery_timeout_seconds": 60,
        "half_open_max_calls": 2
    },
    "coinbase_wallet": {
        "failure_threshold": 2,  # Lower threshold for financial operations
        "recovery_timeout_seconds": 300,  # Longer recovery for economic safety
        "half_open_max_calls": 1
    },
    "weaviate_vector_db": {
        "failure_threshold": 5,
        "recovery_timeout_seconds": 30,
        "half_open_max_calls": 5
    },
    "openclaw_network": {
        "failure_threshold": 10,  # More tolerant of external network issues
        "recovery_timeout_seconds": 180,
        "half_open_max_calls": 3
    }
}
```

---

## Human-in-the-Loop (HITL) Escalation Protocol

### Escalation Triggers

| Error Category | Escalation Trigger | Response Time SLA | Notification Channels |
|----------------|-------------------|-------------------|----------------------|
| **Security Violations** | Immediate | < 5 minutes | PagerDuty, Slack (security), Email (CISO) |
| **Economic Anomalies** | Immediate | < 15 minutes | Slack (finance), Email (CFO) |
| **Data Corruption** | Immediate | < 30 minutes | Slack (engineering), PagerDuty |
| **Budget Exceeded (Critical Campaign)** | Conditional | < 1 hour | Slack (ops), Email (campaign manager) |
| **Repeated Content Violations** | After 3 failures | < 2 hours | Slack (content-ops) |
| **Authentication Failures** | After 1 failure | < 1 hour | Slack (devops), Email (on-call) |

### HITL Queue Implementation

**Redis Queue Schema**:
```python
# HITL escalation queue
# Key: chimera:hitl:queue:{priority}
# Type: Sorted Set (scored by timestamp for FIFO within priority)

await redis.zadd(
    "chimera:hitl:queue:critical",
    {
        json.dumps({
            "escalation_id": "esc_uuid_v4",
            "agent_id": "agent_001",
            "timestamp": "2026-02-06T10:30:00Z",
            "error_type": "SecurityViolationError",
            "reason": "Unauthorized credential access attempt",
            "context": {
                "attempted_credential": "REDACTED",
                "caller_agent_role": "ContentCreationWorker",
                "expected_role": "Orchestrator"
            },
            "forensic_snapshot_id": "forensic_20260206_103000",
            "recommended_action": "Review credential access logs and suspend agent if malicious",
            "severity": "critical"
        }): time.time()
    }
)
```

**HITL Dashboard API**:
```python
@router.get("/api/v1/hitl/queue")
async def get_hitl_queue(
    priority: Optional[str] = None,
    limit: int = 50
) -> List[HITLEscalation]:
    """
    Retrieve pending HITL escalations for human review.
    """
    if priority:
        queue_key = f"chimera:hitl:queue:{priority}"
        escalations = await redis.zrange(queue_key, 0, limit - 1)
    else:
        # Retrieve from all priority queues, ordered by priority then timestamp
        escalations = []
        for p in ["critical", "high", "medium", "low"]:
            queue_items = await redis.zrange(f"chimera:hitl:queue:{p}", 0, limit)
            escalations.extend(queue_items)
    
    return [json.loads(e) for e in escalations]

@router.post("/api/v1/hitl/{escalation_id}/resolve")
async def resolve_hitl_escalation(
    escalation_id: str,
    resolution: HITLResolution
) -> dict:
    """
    Mark HITL escalation as resolved with human decision.
    """
    # Remove from queue
    for priority in ["critical", "high", "medium", "low"]:
        await redis.zrem(f"chimera:hitl:queue:{priority}", escalation_id)
    
    # Log resolution
    await log_hitl_resolution(
        escalation_id=escalation_id,
        resolver=resolution.human_operator_id,
        decision=resolution.decision,
        notes=resolution.resolution_notes
    )
    
    # Execute resolution action
    if resolution.decision == "resume_agent":
        await agent_registry.resume_agent(resolution.agent_id)
    elif resolution.decision == "permanently_suspend":
        await agent_registry.suspend_agent(resolution.agent_id, permanent=True)
    elif resolution.decision == "modify_constraints":
        await update_agent_constraints(resolution.agent_id, resolution.new_constraints)
    
    return {"status": "resolved", "escalation_id": escalation_id}
```

---

## Graceful Degradation Strategies

### 1. Content Generation Fallbacks

**Strategy**: Maintain quality while gracefully degrading to simpler generation methods.

```python
async def generate_content_with_fallbacks(
    task: ContentCreationTask
) -> GeneratedContent:
    """
    Multi-tier content generation with graceful degradation.
    """
    try:
        # Tier 1: Advanced model (GPT-4, Claude Opus)
        return await generate_with_advanced_model(task)
    
    except (RateLimitError, ServiceUnavailableError) as e:
        await log_fallback_attempt(tier="advanced", error=str(e))
        
        try:
            # Tier 2: Standard model (GPT-3.5)
            return await generate_with_standard_model(task)
        
        except (RateLimitError, ServiceUnavailableError) as e2:
            await log_fallback_attempt(tier="standard", error=str(e2))
            
            # Tier 3: Template-based generation
            return await generate_from_templates(task)

async def generate_from_templates(task: ContentCreationTask) -> GeneratedContent:
    """
    Fallback to template-based content when AI generation unavailable.
    """
    template = await load_template_for_persona(
        persona_id=task.persona_id,
        content_type=task.platform
    )
    
    content = template.render(
        topic=task.topic,
        personality=task.persona_traits,
        current_trends=await get_cached_trends()  # Use cached data
    )
    
    return GeneratedContent(
        content=content,
        generation_method="template_fallback",
        confidence_score=0.65,  # Lower confidence for template-based
        requires_review=True
    )
```

### 2. Memory System Degradation

**Strategy**: Degrade from long-term semantic search to short-term only when Weaviate unavailable.

```python
async def retrieve_agent_memory_with_fallback(
    agent_id: str,
    query: str
) -> List[Memory]:
    """
    Memory retrieval with graceful degradation.
    """
    try:
        # Full memory: Short-term (Redis) + Long-term (Weaviate semantic search)
        short_term = await redis_memory.get_recent_context(agent_id, limit=10)
        long_term = await weaviate_memory.semantic_search(
            agent_id=agent_id,
            query=query,
            limit=5
        )
        return short_term + long_term
    
    except WeaviateUnavailableError:
        await log_degradation(component="memory", mode="short_term_only")
        
        # Degraded mode: Short-term memory only
        short_term = await redis_memory.get_recent_context(agent_id, limit=20)
        return short_term

async def store_agent_memory_with_fallback(
    agent_id: str,
    memory: Memory
):
    """
    Memory storage with fallback to delayed ingestion queue.
    """
    # Always store in Redis (short-term)
    await redis_memory.store(agent_id, memory)
    
    try:
        # Attempt long-term storage in Weaviate
        await weaviate_memory.store_with_embedding(agent_id, memory)
    
    except WeaviateUnavailableError:
        # Queue for delayed ingestion when Weaviate recovers
        await redis.rpush(
            f"chimera:memory:delayed_ingestion:{agent_id}",
            json.dumps(memory.dict())
        )
        await log_degradation(
            component="memory_storage",
            mode="queued_for_later",
            queue_length=await redis.llen(f"chimera:memory:delayed_ingestion:{agent_id}")
        )
```

### 3. Heartbeat Degradation

**Strategy**: Reduce heartbeat frequency during high system load.

```python
class AdaptiveHeartbeatController:
    """
    Dynamically adjust heartbeat frequency based on system health.
    """
    
    def __init__(self):
        self.normal_interval = 30  # seconds
        self.degraded_interval = 60  # seconds
        self.minimal_interval = 120  # seconds
    
    async def get_current_interval(self) -> int:
        """
        Determine heartbeat interval based on system load.
        """
        system_load = await get_system_metrics()
        
        if system_load.redis_cpu > 80 or system_load.network_latency > 500:
            # Minimal mode: Reduce heartbeat load
            await log_degradation(
                component="heartbeat",
                mode="minimal",
                interval=self.minimal_interval
            )
            return self.minimal_interval
        
        elif system_load.redis_cpu > 60 or system_load.network_latency > 200:
            # Degraded mode: Moderate reduction
            await log_degradation(
                component="heartbeat",
                mode="degraded",
                interval=self.degraded_interval
            )
            return self.degraded_interval
        
        else:
            # Normal mode
            return self.normal_interval
```

---

## Error Logging & Observability

### Structured Error Logging

**Log Format** (JSON):
```json
{
  "timestamp": "2026-02-06T10:30:45.123Z",
  "log_level": "error",
  "error_code": "ERR_BUDGET_EXCEEDED",
  "error_category": "permanent",
  "agent_id": "agent_001",
  "persona_id": "persona_crypto_influencer",
  "operation": "execute_payment",
  "error_message": "Transaction would exceed daily limit of $50",
  "context": {
    "attempted_amount": 25.00,
    "current_daily_spend": 35.00,
    "daily_limit": 50.00,
    "transaction_recipient": "0xREDACTED",
    "campaign_id": "campaign_viral_nft"
  },
  "stack_trace": "REDACTED",
  "resolution_status": "escalated_to_cfo",
  "correlation_id": "corr_uuid_v4"
}
```

### Grafana Dashboard Metrics

**Error Rate Metrics** (Prometheus + Grafana):
```python
# Prometheus metrics for error tracking
chimera_errors_total = Counter(
    'chimera_errors_total',
    'Total error count by category and type',
    ['error_category', 'error_code', 'agent_id']
)

chimera_retry_attempts_total = Counter(
    'chimera_retry_attempts_total',
    'Total retry attempts by function',
    ['function_name', 'error_type']
)

chimera_circuit_breaker_state = Gauge(
    'chimera_circuit_breaker_state',
    'Circuit breaker state (0=closed, 1=half_open, 2=open)',
    ['service_name']
)

chimera_hitl_escalations_total = Counter(
    'chimera_hitl_escalations_total',
    'Total HITL escalations by priority',
    ['priority', 'error_type']
)

chimera_hitl_resolution_time_seconds = Histogram(
    'chimera_hitl_resolution_time_seconds',
    'Time to resolve HITL escalations',
    ['priority'],
    buckets=[60, 300, 900, 1800, 3600, 7200]  # 1min to 2 hours
)
```

**Grafana Alert Rules**:
```yaml
groups:
  - name: chimera_error_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(chimera_errors_total[5m]) > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected in Chimera fleet"
          description: "Error rate is {{ $value }} errors/sec"
      
      - alert: CriticalErrorSpike
        expr: rate(chimera_errors_total{error_category="critical"}[5m]) > 1
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Critical errors detected - immediate attention required"
      
      - alert: CircuitBreakerOpen
        expr: chimera_circuit_breaker_state{service_name="coinbase_wallet"} == 2
        for: 5m
        labels:
          severity: high
        annotations:
          summary: "Circuit breaker open for {{ $labels.service_name }}"
      
      - alert: HITLBacklog
        expr: sum(rate(chimera_hitl_escalations_total[10m])) > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "HITL escalation backlog growing - human review capacity needed"
```

---

## Error Handling Testing Strategy

### Unit Tests

```python
@pytest.mark.asyncio
async def test_retry_with_exponential_backoff_success_after_retries():
    """Test successful retry after transient failures."""
    call_count = 0
    
    async def flaky_function():
        nonlocal call_count
        call_count += 1
        if call_count < 3:
            raise TransientNetworkError("Connection timeout")
        return "success"
    
    result = await retry_with_exponential_backoff(
        flaky_function,
        max_retries=3,
        base_delay_ms=10  # Fast for testing
    )
    
    assert result == "success"
    assert call_count == 3

@pytest.mark.asyncio
async def test_budget_exceeded_no_retry():
    """Test that permanent errors are not retried."""
    call_count = 0
    
    async def budget_violation_function():
        nonlocal call_count
        call_count += 1
        raise BudgetExceededError("Daily limit exceeded")
    
    with pytest.raises(BudgetExceededError):
        await retry_with_exponential_backoff(
            budget_violation_function,
            max_retries=3
        )
    
    assert call_count == 1  # Should not retry

@pytest.mark.asyncio
async def test_circuit_breaker_opens_after_threshold():
    """Test circuit breaker opens after failure threshold."""
    circuit_breaker = CircuitBreaker(
        service_name="test_service",
        failure_threshold=3,
        recovery_timeout_seconds=60
    )
    
    async def failing_function():
        raise ServiceUnavailableError("Service down")
    
    # First 3 failures should attempt calls
    for _ in range(3):
        with pytest.raises(ServiceUnavailableError):
            await circuit_breaker.call(failing_function)
    
    # 4th attempt should fail immediately with CircuitOpenError
    with pytest.raises(CircuitOpenError):
        await circuit_breaker.call(failing_function)
    
    state = await circuit_breaker._get_state()
    assert state == CircuitState.OPEN
```

### Integration Tests

```python
@pytest.mark.integration
@pytest.mark.asyncio
async def test_end_to_end_content_generation_fallback():
    """Test content generation gracefully falls back through tiers."""
    
    # Simulate OpenAI rate limit
    with mock_openai_rate_limit():
        task = ContentCreationTask(
            persona_id="test_persona",
            platform="twitter",
            topic="AI trends"
        )
        
        result = await generate_content_with_fallbacks(task)
        
        # Should have fallen back to template generation
        assert result.generation_method == "template_fallback"
        assert result.confidence_score < 0.7
        assert result.requires_review is True

@pytest.mark.integration
@pytest.mark.asyncio
async def test_security_violation_escalation_flow():
    """Test complete HITL escalation flow for security violations."""
    
    # Trigger security violation
    error = SecurityViolationError(
        agent_id="test_agent_001",
        violation_type="UnauthorizedCredentialAccess"
    )
    
    await handle_security_violation(error)
    
    # Verify agent suspended
    agent_status = await agent_registry.get_status("test_agent_001")
    assert agent_status == "suspended"
    
    # Verify HITL escalation queued
    escalations = await redis.zrange("chimera:hitl:queue:critical", 0, -1)
    assert len(escalations) > 0
    
    escalation_data = json.loads(escalations[0])
    assert escalation_data["agent_id"] == "test_agent_001"
    assert escalation_data["error_type"] == "SecurityViolationError"
```

---

## Implementation Checklist

### Phase 1: Core Error Handling (Week 1)
- [ ] Implement base exception classes for all error categories
- [ ] Create retry_with_exponential_backoff utility function
- [ ] Implement rate limit aware retry logic
- [ ] Add structured error logging middleware to FastAPI
- [ ] Create Prometheus metrics for error tracking

### Phase 2: Circuit Breakers (Week 2)
- [ ] Implement Redis-based CircuitBreaker class
- [ ] Configure circuit breakers for all external services (Twitter, OpenAI, Coinbase, Weaviate, OpenClaw)
- [ ] Add circuit breaker state monitoring to Grafana
- [ ] Create circuit breaker override API for manual control

### Phase 3: HITL Escalation (Week 2)
- [ ] Implement HITL escalation queue in Redis
- [ ] Create HITL dashboard API endpoints
- [ ] Build HITL web UI for human operators
- [ ] Integrate PagerDuty/Slack notifications
- [ ] Add HITL resolution workflow

### Phase 4: Graceful Degradation (Week 3)
- [ ] Implement content generation fallback tiers
- [ ] Add memory system degradation (Weaviate → Redis only)
- [ ] Create adaptive heartbeat controller
- [ ] Test all degradation scenarios under load

### Phase 5: Testing & Validation (Week 3)
- [ ] Write unit tests for all error handlers (80% coverage)
- [ ] Create integration tests for fallback flows
- [ ] Load test circuit breakers under simulated failures
- [ ] Chaos engineering: Inject failures and validate recovery

### Phase 6: Observability & Monitoring (Week 4)
- [ ] Deploy Grafana dashboards for error metrics
- [ ] Configure alerting rules for critical errors
- [ ] Create runbooks for common error scenarios
- [ ] Train operations team on HITL dashboard

---

## Integration with Existing Specifications

### Security.md Integration
- **Budget enforcement**: All `BudgetExceededError` handling aligns with [security.md](specs/security.md#L33) CFO Judge Agent requirements
- **Credential failures**: `AuthenticationError` handling follows [security.md](specs/security.md#L77) credential rotation protocols
- **Economic anomalies**: Anomaly detection triggers match [security.md](specs/security.md#L62) audit trail requirements

### Heartbeat.md Integration
- **Health status reporting**: Errors update agent health status in [heartbeat.md](specs/heartbeat.md#L84) `status` field
- **Degradation signals**: Circuit breaker states reflected in heartbeat `health_metrics`
- **Availability impact**: Open circuits set `skill_availability` to unavailable in [heartbeat.md](specs/heartbeat.md#L150)

### Memory.md Integration
- **Weaviate fallback**: Memory degradation strategy aligns with [memory.md](specs/memory.md) Redis/Weaviate hierarchy
- **Delayed ingestion**: Queued memories processed during recovery match [memory.md](specs/memory.md#L627) archival patterns

### Technical.md Integration
- **JSON schemas**: Error response schemas extend [technical.md](specs/technical.md#L60) ChimeraTask validation patterns
- **Database constraints**: Foreign key violation handling respects [technical.md](specs/technical.md#L535) referential integrity

---

## Appendix: Error Code Reference

| Error Code | Category | Retry | Escalation | Severity |
|-----------|----------|-------|------------|----------|
| `ERR_NETWORK_TRANSIENT` | Transient | Yes (exp backoff) | No | Low |
| `ERR_RATE_LIMIT` | Transient | Yes (wait for reset) | No | Low |
| `ERR_SERVICE_UNAVAILABLE` | Transient | Yes (circuit breaker) | After threshold | Medium |
| `ERR_AUTH_FAILED` | Permanent | No | Immediate HITL | Critical |
| `ERR_BUDGET_EXCEEDED` | Permanent | No | CFO Judge | High |
| `ERR_CONTENT_VIOLATION` | Permanent | Regenerate with constraints | After 3 failures | Medium |
| `ERR_VALIDATION_FAILED` | Permanent | No | Log and reject | Low |
| `ERR_SECURITY_BREACH` | Critical | No | Immediate HITL + Suspend | Critical |
| `ERR_DATA_CORRUPTION` | Critical | No | Immediate HITL + Rollback | Critical |
| `ERR_ECONOMIC_ANOMALY` | Critical | No | Immediate HITL + Freeze | Critical |

---

**Document Status**: ✅ Complete and ready for implementation  
**Next Steps**: Begin Phase 1 implementation (Core Error Handling)
