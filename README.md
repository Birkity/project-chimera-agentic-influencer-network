# Project Chimera 🔥


[![TDD Approach](https://img.shields.io/badge/testing-TDD--failing--tests-orange.svg)](tests/)
[![OpenClaw Compatible](https://img.shields.io/badge/openclaw-compatible-blue.svg)](specs/openclaw_integration.md)
[![10 Academy](https://img.shields.io/badge/10%20Academy-Week%200%20Challenge-green.svg)](deliverables/)

**Specification-First Autonomous AI Influencer Network Design**

**🚨 This is a specification and architecture prototype for the 10 Academy AI Engineering Challenge Week 0. The project demonstrates specification-driven development methodology with comprehensive technical documentation, TDD test cases, and production-ready architecture design - implementation is intentionally minimal to focus on demonstrating engineering best practices.**

Project Chimera defines an autonomous AI system architecture for creating persistent, goal-directed digital entities with "Autonomy with Bounded Risk" - featuring economic agency, cross-agent collaboration, and comprehensive security frameworks.

## 🎯 Core Capabilities

### Content & Intelligence
- **Multi-Platform Content Creation**: Autonomous video, image, and text generation for Twitter, Instagram, TikTok, YouTube Shorts
- **Real-Time Market Intelligence**: Weaviate-powered trend analysis with semantic search and sentiment scoring
- **Agent Persona System**: SOUL.md-based personality definitions with GitOps versioning
- **Memory Architecture**: Hierarchical short-term (Redis) and long-term (Weaviate) memory with RAG pipeline

### Economic & Security
- **Bounded Economic Agency**: $50 daily limits with CFO Judge Agent oversight and automatic HITL escalation
- **Comprehensive Security**: Multi-layer defense with credential vaults, content filtering, and audit trails
- **Error Handling & Resilience**: Circuit breakers, exponential backoff, graceful degradation, and 99.9% uptime
- **Health Monitoring**: 30-second heartbeat broadcasting with performance metrics and availability tracking

### Network & Collaboration  
- **OpenClaw Network Integration**: Agent discovery, persona publishing, and secure cross-agent task assignment
- **Fleet Orchestration**: Support for 1000+ concurrent agents with <10 second response latency
- **MCP-Based Architecture**: Modular integrations using Model Context Protocol for all external services

## 🏗️ Architecture

### FastRender Swarm Pattern

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Orchestrator  │◄──►│  Planner Agent  │◄──►│  Judge Agent    │
│  (Fleet Mgmt)   │    │ (Task Decomp)   │    │ (Quality Gate)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Worker Agent Pool                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   Content   │  │   Market    │  │   Social    │    ...     │
│  │  Creation   │  │Intelligence │  │ Engagement  │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                        MCP Layer                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   Twitter   │  │  Coinbase   │  │  Weaviate   │    ...     │
│  │     MCP     │  │     MCP     │  │     MCP     │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

**Agent Types**:
- **Planner Agent**: Strategic task decomposition, resource allocation, dynamic re-planning
- **Worker Pool**: Stateless agents for content creation, market intelligence, social engagement
- **Judge Agent**: Quality assurance, confidence scoring, CFO budget oversight, content policy enforcement
- **Orchestrator**: Fleet coordination, health monitoring, OpenClaw network interface

### Security & Risk Management

**"Autonomy with Bounded Risk" Architecture**:
- **Economic Security**: $50 daily limits, $20 transaction caps, CFO Judge Agent oversight
- **Content Security**: Multi-layer filtering, platform compliance, toxicity detection
- **Credential Security**: Vault-based key management, credential rotation, access logging
- **Network Security**: Zero-trust architecture, continuous monitoring, threat detection

### Memory & Context System

**Hierarchical Memory Architecture**:
- **Short-Term Memory (Redis)**: 1-hour sliding window for immediate context
- **Long-Term Memory (Weaviate)**: Semantic search with vector embeddings for historical context  
- **Context Assembly**: RAG pipeline combining SOUL.md persona + memories for agent behavior
- **Memory Evolution**: Automatic archival based on importance scoring and retention policies

### Error Handling & Resilience

**Three-Tier Error Classification**:
- **Transient Errors**: Exponential backoff with circuit breakers (network, rate limits, service unavailability)
- **Permanent Errors**: No retry with structured escalation (auth failures, budget violations, validation errors)
- **Critical Errors**: Immediate HITL escalation (security breaches, data corruption, economic anomalies)

**Graceful Degradation**:
- Content Generation: GPT-4 → GPT-3.5 → Template fallback
- Memory System: Weaviate + Redis → Redis-only mode
- Heartbeat: 30s → 60s → 120s intervals under load

### Confidence-Based Human-in-the-Loop

- **High Confidence (≥90%)**: Autonomous execution with audit logging
- **Medium Confidence (70-89%)**: Human review recommended, proceed with monitoring
- **Low Confidence (<70%)**: Automatic rejection with HITL escalation and analysis

## 🚀 Quick Start

### Prerequisites

- **Python 3.11+** (tested with Python 3.13.7)
- **[uv](https://docs.astral.sh/uv/)** for dependency management (recommended)
- **Docker & Docker Compose** for development services
- **Git** for version control
- **VS Code** recommended for development

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/Birkity/project-chimera-agentic-influencer-network


# Setup with uv (recommended)
make setup

# Or manual setup:
python -m venv .venv
# Windows
.venv\Scripts\Activate.ps1
# Install dependencies
uv sync --dev

# Start development services
docker-compose -f docker/docker-compose.dev.yml up -d

# Run TDD validation tests (designed to fail - demonstrates test-first approach)
python -m pytest tests/ -v
```

### Configuration

**Note**: As a specification prototype, external API keys are not required for validation. The development stack runs locally with Docker services defined in `docker/docker-compose.dev.yml`.

### Available Commands (Makefile)

```bash
# Setup development environment (interactive)
make setup

# View all available commands
make help

# Run TDD validation tests 
make test

# Start development services
make docker-up

# Check specification compliance
make validate-specs

# Install dependencies only
make install
```

## � Project Structure (Current State)

**This project follows a specification-first approach - comprehensive documentation and test cases exist before implementation.**

```
10-academy-week-0/
├── specs/                        # 📋 Complete Technical Specifications (9 documents)
│   ├── _meta.md                  # Project vision, business model, constraints
│   ├── functional.md             # User stories, epics, acceptance criteria
│   ├── technical.md              # API contracts, schemas, database design
│   ├── security.md               # "Autonomy with Bounded Risk" framework
│   ├── personas.md               # SOUL.md format definitions
│   ├── memory.md                 # Hierarchical memory (Redis + Weaviate)
│   ├── heartbeat.md              # Health monitoring & availability
│   ├── openclaw_integration.md   # Agent network protocol
│   └── error_handling.md         # Resilience patterns & HITL escalation
├── chimera/                    # 🐍 Core Python Package (Architecture Stub)
│   ├── __init__.py              # Package marker
│   └── __pycache__/             # Compiled Python bytecode
├── skills/                     # 🎯 Agent Skills Interface Design
│   ├── content_creation/        # Content generation pipeline (planned)
│   ├── market_intelligence/     # Trend analysis capabilities (planned) 
│   ├── social_engagement/       # Platform interaction skills (planned)
│   ├── __init__.py             
│   └── README.md               # Skills interface specification
├── tests/                      # 🧪 Test-Driven Development (Failing by Design)
│   ├── test_trend_fetcher.py    # Market intelligence validation
│   ├── test_skills_interface.py # Skills contract testing
│   └── __init__.py
├── docker/                     # 🐳 Development Infrastructure
│   └── docker-compose.dev.yml   # PostgreSQL, Redis, Weaviate, MCP servers
├── .github/                    # 🤖 CI/CD & Development Tools
│   ├── workflows/              # GitHub Actions (planned)
│   ├── copilot-instructions.md # AI assistant context rules
│   ├── chatmodes/              # Custom AI chat configurations
│   └── ide-chat-history/       # Development session logs
├── deliverables/              # 📄 Challenge Submissions
│   ├── architecture_strategy.md # Design methodology
│   └── summary_doc.tex         # LaTeX project summary
├── .vscode/                   # VS Code configuration
├── pyproject.toml            # Python project configuration (uv compatible)
├── Makefile                  # Development task automation
├── Dockerfile               # Container definition
├── .coderabbit.yaml         # AI code review configuration
└── README.md                # This file
```

### 🎯 What Exists vs. What's Planned

#### ✅ **Implemented (Specification-Complete)**:
- **Complete Technical Specifications**: 9 comprehensive documents (4,000+ lines)
- **Test-Driven Development**: Failing tests that define success criteria
- **Development Infrastructure**: Docker services, Makefile, dependency management
- **AI Development Tooling**: Copilot instructions, CodeRabbit configuration
- **Architecture Documentation**: Technical diagrams, API contracts, data schemas

#### 📋 **Planned (Implementation Ready)**:
- **Agent Implementation**: Planner, Worker Pool, Judge Agent classes
- **Skills System**: Content creation, market intelligence, social engagement modules
- **API Endpoints**: FastAPI implementation of technical specification
- **Security Framework**: Budget management, credential vaults, content filtering
- **Memory System**: Redis/Weaviate integration with RAG pipeline

## 🎨 Skills Architecture (Specification Phase)

### Current State: Interface Design Complete

The skills system is **fully specified** but **intentionally not implemented** - demonstrating specification-first development where architecture and contracts are defined before coding begins.

### Content Creation Pipeline (Planned)

**Multi-Platform Content Generation**:
- `skill_download_video`: Video acquisition with metadata extraction (specification complete)
- `skill_transcribe_audio`: Speech-to-text with timestamping (API contracts defined)
- `skill_generate_caption`: Platform-specific content optimization (schema ready)
- `skill_create_social_post`: End-to-end content pipeline (user stories defined)

**Implementation Ready**: All input/output schemas, error handling, and success criteria defined in [skills/README.md](skills/README.md)

### Market Intelligence (Planned)

**Trend Analysis & Insights**:
- `skill_analyze_trends`: Weaviate semantic search integration (technical spec complete)
- `skill_fetch_news`: News aggregation with relevance filtering (API design done)
- `skill_sentiment_analysis`: Multi-platform sentiment tracking (data models ready)
- `skill_competitive_analysis`: Performance monitoring framework (architecture defined)

**Validation**: Test cases exist in [tests/test_trend_fetcher.py](tests/test_trend_fetcher.py) - currently failing as expected

### Social Engagement (Planned)

**Automated Interaction Management**:
- `skill_reply_comments`: Context-aware responses (personality consistency algorithms specified)
- `skill_schedule_posts`: Optimal timing analysis (prediction models designed)
- `skill_analyze_metrics`: Performance tracking (data pipeline architecture complete)
- `skill_community_management`: Relationship building (engagement strategies documented)

### Skills Interface Contract

**Standardized Input/Output**:
```python
# All skills follow this interface (from skills/README.md)
async def skill_function(input_data: SkillInput) -> SkillOutput:
    """
    Standard skill interface with:
    - Validated input schemas (Pydantic models)
    - Confidence scoring (0.0-1.0 for HITL routing)
    - Error handling (circuit breakers, retry logic)
    - Performance metrics (execution time, resource usage)
    """
```

**Note**: Skills directories exist but are intentionally empty - implementation would follow the comprehensive specifications and test cases already defined.

## 🔐 Security & Economic Framework

### "Autonomy with Bounded Risk" Principles

**Economic Security Controls**:
- **Daily Spending Limits**: $50 maximum per agent with automatic reset
- **Transaction Caps**: $20 single transaction limit with escalation protocols
- **CFO Judge Agent**: Automated budget oversight with exception handling
- **Audit Trail**: Immutable transaction logging with compliance reporting

**Credential & Key Management**:
- **Vault Integration**: Enterprise-grade secret storage (HashiCorp Vault, AWS Secrets Manager)
- **Key Rotation**: Automatic 90-day rotation with zero-downtime updates
- **Access Logging**: Comprehensive credential access monitoring
- **Zero-Trust Architecture**: All interactions validated regardless of source

**Content Security Pipeline**:
- **Multi-Layer Filtering**: Toxicity, copyright, brand safety, platform compliance
- **Content Policy Enforcement**: Platform-specific guideline compliance
- **Human Escalation**: Low-confidence content routed for review
- **Legal Compliance**: GDPR, CCPA, platform terms of service adherence

### Error Handling & Resilience

**Circuit Breaker Pattern**:
- **External Service Protection**: Twitter API, OpenAI, Coinbase, Weaviate circuit breakers
- **Failure Threshold Management**: Service-specific failure tolerances
- **Automatic Recovery**: Health-check based service restoration
- **Graceful Degradation**: Fallback strategies for partial service availability

**Human-in-the-Loop (HITL) Escalation**:
- **Priority Queue System**: Critical, High, Medium, Low escalation categories
- **SLA Enforcement**: Security (<5min), Economic (<15min), Technical (<30min)
- **Resolution Workflow**: Structured decision making with audit trails
- **Notification Channels**: PagerDuty, Slack, Email integration

## 💾 Memory & Context System

### Hierarchical Memory Architecture

**Short-Term Memory (Redis)**:
- **Conversation Context**: 1-hour sliding window for immediate interactions
- **Task History**: Recent task execution results and performance metrics
- **Emotional State**: Current mood and interaction patterns
- **Budget Tracking**: Real-time spend monitoring and daily accumulation

**Long-Term Memory (Weaviate)**:
- **Semantic Knowledge**: Vector-embedded memories with similarity search
- **Persona Evolution**: Personality adaptation based on successful interactions
- **Market Intelligence**: Historical trend data and pattern recognition
- **Relationship Mapping**: User interaction history and preference learning

**Context Assembly Pipeline**:
- **SOUL.md Integration**: Personality-driven context generation
- **Memory Retrieval**: Semantic search combining short and long-term memories
- **Context Prompt Assembly**: Structured prompt generation for consistency
- **Memory Archival**: Importance-based long-term storage decisions

## 🔗 MCP (Model Context Protocol) Integration

Project Chimera uses MCP servers as the **middleware layer** for all external integrations, providing standardized, secure, and scalable service access.

### Development MCP Servers

**Local Development Stack**:
- **`git-mcp`**: Version control operations and repository management
- **`filesystem-mcp`**: File system operations with security boundaries
- **`postgres-mcp`**: Database operations with transaction management
- **Built-in Services**: Redis (task queuing), Weaviate (vector storage)

### Production MCP Servers  

**External Service Integration**:
- **`twitter-mcp`**: Social media API integration with rate limiting and authentication
- **`coinbase-mcp`**: Blockchain transaction management with security controls
- **`weaviate-mcp`**: Vector database operations with semantic search capabilities
- **`openclaw-mcp`**: Agent network protocol for cross-agent communication
- **`openai-mcp`**: AI model access with usage tracking and cost optimization

**MCP Benefits**:
- **Security Isolation**: Agents never handle API credentials directly
- **Rate Limit Management**: Centralized throttling and retry logic
- **Protocol Normalization**: Consistent interfaces across diverse APIs
- **Monitoring & Observability**: Centralized logging and metrics collection

## 🌐 OpenClaw Network Integration

### Agent Network Participation

**SOUL.md Persona Publishing**:
- **Agent Discovery**: Personality and capability broadcasting to network
- **Skill Marketplace**: Available capabilities exposure for task assignment
- **Trust Registry**: Reputation and reliability scoring system
- **Collaboration Protocol**: Secure cross-agent task delegation

**Heartbeat & Health Monitoring**:
- **30-Second Broadcasts**: Real-time availability and performance metrics
- **Fleet Coordination**: Internal agent health monitoring via Redis Pub/Sub
- **External Discovery**: OpenClaw network status broadcasting via HTTP/WebSocket
- **Degradation Handling**: Adaptive heartbeat frequency based on system load

**Cross-Agent Task Assignment**:
- **Skill Matching**: Capability-based task routing across agent networks
- **Economic Integration**: Cross-network payment and incentive systems
- **Security Framework**: Credential gateway and trust validation
- **Quality Assurance**: Performance tracking and feedback loops

## 💰 Economic Agency & Business Models

### Revenue Streams

**Direct Monetization**:
- **Digital Talent Agency**: Own and operate flagship AI influencers across platforms
- **Sponsored Content**: Brand partnerships and promotional content generation  
- **Audience Monetization**: Subscription services and exclusive content offerings
- **Cross-Platform Arbitrage**: Content optimization for multiple platform algorithms

**Platform-as-a-Service (PaaS)**:
- **"Chimera OS" Licensing**: White-label AI influencer infrastructure for enterprises
- **Custom Agent Development**: Bespoke AI personalities for brand marketing
- **API Access**: Third-party integration with Chimera agent capabilities
- **Hybrid Ecosystems**: Combined owned content and licensed platform services

### Economic Controls & Compliance

**Autonomous Transaction Management**:
- **Spending Envelopes**: Predefined daily ($50) and transaction ($20) limits per agent
- **Multi-Signature Security**: Enterprise-grade wallet management with key rotation
- **Automatic Escalation**: Human approval required for transactions exceeding bounds
- **Regulatory Compliance**: AML/KYC integration for financial operations

**Performance Metrics & ROI**:
- **Content Performance**: Engagement rates, virality scores, conversion tracking
- **Economic Efficiency**: Cost per engagement, revenue per follower, platform ROI
- **Risk Management**: Spending variance analysis, anomaly detection, budget forecasting
- **Audit & Reporting**: Complete transaction history with tax and compliance exports

## 🧪 Test-Driven Development (TDD) Approach

### Methodology: Failing Tests Define Success

**This project demonstrates TDD at the specification level** - comprehensive test cases exist before implementation, designed to fail until the actual system is built.

```bash
# Run validation tests (expected to fail)
python -m pytest tests/ -v

# Current test files:
tests/test_trend_fetcher.py     # Market intelligence API contracts
tests/test_skills_interface.py  # Agent skills interface validation
```

### TDD Benefits Demonstrated

- **Specification Validation**: Tests prove the specifications are complete and testable
- **API Contract Definition**: Tests define exact input/output schemas before coding
- **Quality Gates**: Clear success criteria for implementation teams
- **Regression Prevention**: Prevent specification drift during development

### Example: Trend Fetcher Test

```python
def test_trend_data_required_fields(self):
    """Assert TrendData contains all required fields from technical spec"""
    # This test SHOULD FAIL - TrendData not implemented
    assert TrendData is not None, "TrendData model not implemented"
    
    required_fields = ['trend_topic', 'platform', 'virality_score', 
                      'sentiment_score', 'content_examples', 'detected_at']
    
    trend_instance = TrendData(...)  # Will fail until implemented
```

The failing tests serve as **implementation guidelines** and **acceptance criteria**.

## 🚀 Deployment & Operations

### Container Orchestration

**Development Environment**:
```bash
# Start all services with monitoring
docker-compose -f docker/docker-compose.dev.yml --profile monitoring up -d

# Services included:
# - PostgreSQL 15 (persistent data)
# - Redis 7 (task queue + short-term memory)  
# - Weaviate 1.22.4 (vector database)
# - Grafana + Loki (observability)
# - pgAdmin (database management)
```

**Production Deployment**:
```bash
# Production-ready with security hardening
docker-compose -f docker/docker-compose.prod.yml up -d

# Features:
# - Multi-container agent scaling
# - Load balancing with health checks
# - Persistent volume management
# - Security scanning and updates
# - Backup and disaster recovery
```

### Monitoring & Observability

**Metrics & Alerting**:
- **Agent Performance**: Response times, task completion rates, error frequencies
- **Economic Monitoring**: Spending patterns, budget utilization, transaction success rates
- **System Health**: CPU/memory usage, service availability, database performance
- **Security Events**: Failed authentication, policy violations, anomaly detection

**Dashboard & Reporting**:
- **Real-Time Fleet Status**: Agent health, task queue depth, service status
- **Business Intelligence**: Revenue tracking, engagement analytics, ROI reporting
- **Error Analysis**: Failure patterns, resolution times, escalation trends
- **Capacity Planning**: Resource usage trends, scaling recommendations

## 🔒 Security & Compliance

### Enterprise Security Standards

**Data Protection**:
- **Encryption at Rest**: Database and file system encryption with key management
- **Encryption in Transit**: TLS 1.3 for all API communications and MCP connections
- **Data Minimization**: GDPR-compliant data collection with retention policies
- **Access Control**: Role-based permissions with principle of least privilege

**Vulnerability Management**:
- **Dependency Scanning**: Automated security updates with vulnerability assessment
- **Static Code Analysis**: SonarQube integration with security rule enforcement
- **Penetration Testing**: Regular security assessments with remediation tracking
- **Incident Response**: 24/7 monitoring with automated response procedures

**Regulatory Compliance**:
- **GDPR Compliance**: Data subject rights, consent management, data portability
- **CCPA Compliance**: California consumer privacy protections and disclosure requirements
- **Platform TOS Compliance**: Automated policy checking for all major social platforms
- **Financial Regulations**: AML/KYC integration for economic transaction compliance

## 🤝 Contributing to Project Chimera

### This is a **Specification & Architecture Project**

**Current Phase**: Specification-driven development demonstration for 10 Academy Challenge  
**Goal**: Showcase engineering excellence through comprehensive documentation and test-driven design

### How to Contribute

#### Option 1: Specification Enhancement
1. **Review Existing Specs**: Examine `specs/` directory for completeness and consistency
2. **Propose Improvements**: Suggest architectural enhancements or clarifications
3. **Cross-Reference Validation**: Ensure specifications align across all 9 documents
4. **Test Case Expansion**: Add more comprehensive TDD test scenarios

#### Option 2: Implementation (Future Phase)
1. **Start with Failing Tests**: Use existing tests in `tests/` as implementation guide
2. **Follow Specifications Exactly**: All implementations must match spec requirements
3. **Maintain TDD Approach**: Red-Green-Refactor methodology
4. **Preserve Architecture**: Maintain FastRender Swarm Pattern and MCP integration

### Development Standards

**Specification Quality**:
- Cross-document consistency (budget limits, API contracts, etc.)
- Complete JSON schemas with examples
- Error handling scenarios documented
- Performance requirements quantified

**Code Quality** (when implementing):
- Pydantic models matching specification schemas
- Circuit breakers and retry logic as specified
- Security controls following "Autonomy with Bounded Risk"
- Comprehensive logging and monitoring hooks

**Security Reviews**:
- Security implications documented for all pull requests
- Credential handling reviewed for vault compliance
- Economic transaction logic validated against limits
- Content filtering tested for policy compliance

### Specification Updates

When modifying system behavior:

1. **Update Specifications First**: Modify relevant `specs/*.md` files
2. **Update Tests**: Reflect specification changes in test cases
3. **Implementation**: Update code to match new specifications
4. **Validation**: Run full test suite and spec compliance checks

### Specification Review Areas

When evaluating or enhancing specifications:

1. **Cross-Document Consistency**: Verify budget limits ($50/day), heartbeat intervals (30s), and API schemas align
2. **Implementation Readiness**: Ensure JSON schemas, database designs, and error codes are complete
3. **Security Framework**: Validate "Autonomy with Bounded Risk" implementation across all subsystems
4. **Integration Points**: Check MCP server definitions and OpenClaw protocol compliance

## 📚 Project Resources

### Core Documentation

- **[Technical Specifications](specs/)**: 9 comprehensive specification documents (4,000+ lines)
  - System architecture, API contracts, security framework, memory systems
- **[Skills Interface](skills/README.md)**: Agent capability definitions and contracts
- **[TDD Test Suite](tests/)**: Failing tests that define implementation success criteria
- **[Development Setup](Makefile)**: Automated environment configuration and validation

### External Standards & Protocols

- **[OpenClaw Network](https://openclaw.network)**: Agent network protocol for cross-agent collaboration
- **[Model Context Protocol](https://modelcontextprotocol.io)**: MCP specification for service integration
- **[10 Academy](https://10academy.org)**: AI Engineering challenge context and objectives

### Implementation Guidance

- **Architecture Pattern**: FastRender Swarm (Planner → Worker Pool → Judge → Orchestrator)
- **Security Model**: "Autonomy with Bounded Risk" with economic limits and HITL escalation
- **Memory System**: Hierarchical Redis (short-term) + Weaviate (long-term) with RAG pipeline
- **Error Handling**: Three-tier classification with circuit breakers and graceful degradation

---