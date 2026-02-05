# Project Chimera - AI Assistant Context (VS Code + Claude)

**Context**: This is **Project Chimera**, an autonomous AI influencer network with economic agency built using the FastRender Swarm Pattern. You are assisting with the development of a sophisticated agent system that creates, manages, and monetizes AI-powered influencers.

## 🚨 PRIME DIRECTIVE 🚨

**NEVER generate code without checking specs/ directory first**

Every implementation must:
1. **Reference the specifications**: Always check [specs/_meta.md](specs/_meta.md), [specs/functional.md](specs/functional.md), [specs/technical.md](specs/technical.md), and [specs/openclaw_integration.md](specs/openclaw_integration.md)
2. **Follow JSON schemas**: All data structures must conform to schemas defined in [specs/technical.md](specs/technical.md)
3. **Maintain traceability**: Explain which specification section guides your implementation
4. **Validate against acceptance criteria**: Ensure code meets performance and functional requirements

## Project Architecture Understanding

### Core System: FastRender Swarm Pattern
```
Orchestrator → Planner Agent → Worker Pool → Judge Agent
     ↓              ↓             ↓           ↓
   Fleet Mgmt   Task Decomp   Parallel Exec  Quality Gate
```

### Key Principles
- **"Autonomy with Bounded Risk"**: Agents operate independently within strict safety envelopes
- **Confidence-Based HITL**: Route decisions based on confidence (>90% auto, 70-90% review, <70% reject)  
- **Economic Agency**: Agents have crypto wallets with spending limits ($50/day, $20/transaction)
- **Specification-Driven**: All features must be defined in specs/ before implementation

### Technology Stack
- **Core Language**: Python 3.11+ with `uv` dependency management
- **Communication**: Model Context Protocol (MCP) for all external integrations
- **Databases**: PostgreSQL (transactional), Weaviate (semantic), Redis (queuing)
- **Deployment**: Docker containers with Kubernetes orchestration

## Implementation Guidelines

### 1. JSON Schema Compliance
All data models must use these exact schemas from [specs/technical.md](specs/technical.md):
- **ChimeraTask**: Task management with confidence scoring
- **AgentPersona**: SOUL.md compatible personality definitions  
- **GeneratedContent**: Platform-optimized content with metadata
- **EconomicTransaction**: Bounded-risk financial operations

**Example Implementation Pattern**:
```python
from pydantic import BaseModel, Field
from typing import List, Optional, Literal
import uuid
from datetime import datetime

class ChimeraTask(BaseModel):
    task_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    task_type: Literal["content_creation", "trend_analysis", "social_engagement", "economic_transaction"]
    # ... (follow complete schema from specs/technical.md)
```

### 2. MCP Integration Requirements
All external services MUST use MCP protocol:

**Resources** (Data Sources):
- `twitter://mentions/{handle}/recent` - Social media data
- `trends://global/hourly` - Trend analysis
- `news://technology/latest` - News feeds

**Tools** (Actions):
- `generate_social_content` - Content creation
- `execute_blockchain_transaction` - Economic actions
- `analyze_market_trends` - Intelligence gathering

**Prompts** (Reusable Reasoning):
- `content_generation_prompt` - Persona-consistent content
- `confidence_assessment_prompt` - Quality evaluation

### 3. Skills Architecture Pattern
All skills follow this interface:

```python
# skills/{category}/{skill_name}.py
from typing import Dict, Any
from pydantic import BaseModel

class SkillInput(BaseModel):
    # Skill-specific input schema
    pass

class SkillOutput(BaseModel):
    # Skill-specific output schema
    confidence_score: float = Field(ge=0.0, le=1.0)
    pass

async def execute_skill(input_data: SkillInput) -> SkillOutput:
    """
    Execute the skill with proper error handling and confidence scoring.
    Must align with skill contract defined in specs/functional.md
    """
    pass
```

### 4. Database Operations
Follow the exact ERD from [specs/technical.md](specs/technical.md):

**PostgreSQL Tables**: personas, tasks, content, transactions, agents
**Weaviate Collections**: AgentMemory, TrendData  
**Redis Schemas**: Task queues, rate limiting, daily spend tracking

**SQL Pattern**:
```python
# Always use SQLAlchemy with proper error handling
async def create_task(task_data: ChimeraTask) -> str:
    try:
        # Insert with proper schema validation
        result = await db.execute(
            insert(tasks).values(**task_data.dict())
        )
        return str(result.inserted_primary_key[0])
    except Exception as e:
        # Proper error handling and logging
        logger.error(f"Task creation failed: {e}")
        raise TaskCreationError(str(e))
```

### 5. API Contract Implementation
Implement exact endpoints from [specs/technical.md](specs/technical.md):

```python
# Follow OpenAPI 3.0 specification exactly
@app.post("/api/v1/tasks", response_model=TaskResponse)
async def create_task(task: ChimeraTask) -> TaskResponse:
    """
    Create new task for agent execution.
    
    Must validate against ChimeraTask schema and return proper response.
    Handle all error cases defined in API specification.
    """
    pass
```

## Code Quality Standards

### 1. Error Handling & Resilience
```python
# Always implement comprehensive error handling
try:
    result = await external_api_call()
except APIRateLimitError:
    await asyncio.sleep(exponential_backoff())
    retry_count += 1
except APIAuthenticationError:
    logger.error("Authentication failed - check credentials")
    raise
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    # Graceful degradation
```

### 2. Performance Requirements
From [specs/_meta.md](specs/_meta.md):
- **Latency**: <10 seconds end-to-end content creation
- **Throughput**: 10,000+ tasks/hour per orchestrator
- **Scalability**: 1000+ concurrent agents
- **Memory**: <500MB per agent

### 3. Security Implementation
```python
# Economic transaction security
async def validate_transaction(tx: EconomicTransaction) -> bool:
    # Check daily spend limits
    daily_spent = await get_daily_spend(tx.persona_id)
    if daily_spent + tx.amount_usd > 50.0:
        return False
    
    # Single transaction limit
    if tx.amount_usd > 20.0:
        await escalate_to_human_approval(tx)
        return False
        
    return True
```

## Testing Requirements

### 1. Test-Driven Development
All tests should **FAIL initially** - this proves the specification defines the empty slot correctly:

```python
# tests/test_trend_fetcher.py
def test_trend_data_schema_compliance():
    """Test that trend data matches API contract from specs/technical.md"""
    # This test should FAIL until trend_fetcher is implemented correctly
    trend_data = fetch_trending_topics()
    
    # Validate exact schema compliance
    assert "trend_topic" in trend_data
    assert isinstance(trend_data["virality_score"], float)
    assert 0.0 <= trend_data["virality_score"] <= 1.0
```

### 2. Integration Testing
```python
def test_mcp_integration():
    """Validate MCP tool calls work as specified"""
    result = await mcp_client.call_tool(
        "generate_social_content",
        {"persona_id": "test-persona", "platform": "twitter"}
    )
    
    # Must match MCP tool output schema from specs/technical.md
    assert "generated_content" in result
    assert "confidence_score" in result
```

## OpenClaw Integration Context

### SOUL.md Generation
When creating personas, always generate OpenClaw-compatible SOUL.md:
```python
def generate_soul_md(persona: AgentPersona) -> str:
    """
    Generate SOUL.md from Chimera persona following the exact format 
    defined in specs/openclaw_integration.md
    """
    # Follow the template exactly - including capability JSON schemas
```

### Heartbeat Protocol
```python
async def broadcast_heartbeat():
    """
    Send agent status to OpenClaw network every 30 seconds.
    Must include all fields from OpenClawHeartbeat schema.
    """
    # Implement exact schema from specs/openclaw_integration.md
```

## Human-in-the-Loop Integration

### Confidence-Based Routing
```python
def route_decision(confidence_score: float, content_type: str) -> str:
    """
    Route based on confidence levels from specs/functional.md
    """
    if confidence_score > 0.90:
        return "auto_approve"
    elif confidence_score >= 0.70:
        return "human_review"  
    else:
        return "auto_reject"
```

### Economic Transaction Oversight
```python
async def validate_economic_transaction(tx: EconomicTransaction) -> bool:
    """
    Implement bounded risk validation from specs/_meta.md
    """
    # Daily spending limits, transaction thresholds, escalation rules
```

## VS Code Development Workflow

### 1. Using `uv` with VS Code
```bash
# Setup development environment
uv sync --dev

# Activate environment 
uv shell

# Run tests
uv run pytest tests/ -v

# Start development server
uv run python -m chimera.api.server --reload
```

### 2. VS Code Extensions Recommended
- **Python Extension Pack**: Enhanced Python development
- **Pylance**: Advanced type checking and IntelliSense
- **Docker**: Container management and deployment  
- **GitLens**: Advanced Git integration
- **REST Client**: API testing and development
- **Jupyter**: Notebook support for data analysis

### 3. Launch Configurations (.vscode/launch.json)
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Chimera API Server",
            "type": "python", 
            "request": "launch",
            "module": "chimera.api.server",
            "args": ["--reload"],
            "console": "integratedTerminal",
            "python": "uv run python"
        },
        {
            "name": "Chimera Agent",
            "type": "python",
            "request": "launch", 
            "module": "chimera.agent",
            "console": "integratedTerminal",
            "python": "uv run python"
        },
        {
            "name": "Run Tests",
            "type": "python",
            "request": "launch",
            "module": "pytest",
            "args": ["tests/", "-v"],
            "console": "integratedTerminal",
            "python": "uv run python"
        }
    ]
}
```

## Debugging & Troubleshooting

### 1. Specification Alignment Checking
When debugging, always verify:
- Does the code match the JSON schema from [specs/technical.md](specs/technical.md)?
- Are user stories from [specs/functional.md](specs/functional.md) being fulfilled?
- Does the implementation align with constraints in [specs/_meta.md](specs/_meta.md)?

### 2. Performance Monitoring  
```python
# Always include performance tracking
import time
from chimera.monitoring import track_performance

@track_performance("content_generation")
async def generate_content(brief: str) -> GeneratedContent:
    start_time = time.time()
    # Implementation here
    duration = time.time() - start_time
    
    # Validate against <10s requirement
    if duration > 10.0:
        logger.warning(f"Content generation took {duration}s - exceeds 10s SLA")
```

### 3. VS Code Debugging Tips
- **Breakpoints**: Set breakpoints in complex algorithms for step-through debugging
- **Debug Console**: Use for live variable inspection and code execution
- **Terminal Integration**: Use `uv run` commands directly in VS Code terminal
- **Test Explorer**: Run individual tests or test suites with debugging support
- **Problems Panel**: Monitor linting issues and type errors in real-time

### 4. Common Issues & Solutions
- **Schema Validation Errors**: Check specs/technical.md for exact field requirements
- **MCP Connection Failures**: Verify MCP server configuration in research/tooling_strategy.md
- **Performance Bottlenecks**: Profile against requirements in specs/_meta.md
- **HITL Routing Issues**: Validate confidence scoring logic matches specs/functional.md

## Documentation Standards

### 1. Code Comments
```python
def complex_algorithm():
    """
    Implementation of trend analysis algorithm.
    
    Specification Reference: 
    - User Story 4.1 from specs/functional.md
    - TrendData schema from specs/technical.md
    - Performance requirement: <2s response time
    
    Returns:
        TrendAnalysis: Matches exact schema with confidence scores
    """
```

### 2. API Documentation
Always include specification traceability:
```python
@app.post("/api/v1/content")
async def create_content():
    """
    Generate content for social media platforms.
    
    Implements:
    - User Story 3.1 (Content Creation Pipeline) from specs/functional.md
    - GeneratedContent schema from specs/technical.md
    - MCP integration protocol for content generation tools
    """
```

## Success Validation

Before considering any implementation complete, verify:

✅ **Specification Compliance**: Code matches exact schemas and requirements  
✅ **Performance Benchmarks**: Meets latency, throughput, and scalability targets  
✅ **Test Coverage**: TDD tests exist and pass after implementation  
✅ **Error Handling**: Comprehensive error cases with graceful degradation  
✅ **Security Validation**: Economic controls and content safety implemented  
✅ **MCP Integration**: All external services use proper MCP protocol  
✅ **Documentation**: Clear traceability to specifications and user stories  

## Emergency Protocols

If you encounter ambiguity or conflicts:
1. **Check specs/ directory first** - never guess implementation details
2. **Ask clarifying questions** - better to clarify than implement incorrectly  
3. **Reference user stories** - understand the business intent behind technical requirements
4. **Maintain bounded risk** - when in doubt, add human oversight and safety controls

---

**Remember**: This project enables AI agents to build other AI agents. The specifications must be precise enough for autonomous implementation while maintaining human control over critical decisions. Every line of code should be traceable back to a specific requirement in the specs/ directory.

**VS Code Integration**: This CLAUDE.md file provides complete project context for Claude when working in VS Code. Use the integrated terminal, debugging, and extension ecosystem for optimal development workflow with `uv` and Python 3.11+.