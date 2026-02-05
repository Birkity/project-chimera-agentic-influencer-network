# Project Chimera - Master Specification Metadata

**Document**: `specs/_meta.md`  
**Version**: 1.0.0  
**Last Updated**: February 5, 2026  
**Status**: DRAFT - Foundation Specification

## High-Level Vision

**Project Chimera** is an autonomous AI influencer network that creates persistent, goal-directed digital entities capable of:

1. **Autonomous Content Creation**: Generate engaging content across multiple social platforms
2. **Real-Time Market Intelligence**: Analyze trends and adapt content strategy dynamically  
3. **Economic Agency**: Execute bounded financial transactions through crypto wallets
4. **Agent Social Network**: Participate in OpenClaw network for agent-to-agent collaboration
5. **Scalable Fleet Management**: Orchestrate 1000+ concurrent agents with human oversight

## Business Models

### Primary Revenue Streams
1. **Digital Talent Agency**: Own and monetize flagship AI influencers directly
2. **Platform-as-a-Service**: License "Chimera OS" to brands for custom AI ambassadors
3. **Hybrid Ecosystem**: Combine owned influencers with platform licensing

### Success Metrics
- **Scale**: Support 1000+ concurrent autonomous agents
- **Performance**: <10 second end-to-end response latency (excluding HITL)
- **Quality**: >90% content requiring no human intervention
- **Revenue**: $1M+ ARR through combined business models

## Technical Constraints

### Architecture Pattern
**FastRender Swarm Pattern** - Hierarchical agent system optimized for parallel execution:
- **Planner Agent**: Strategic task decomposition from high-level goals
- **Worker Pool**: Stateless agents executing atomic tasks in parallel
- **Judge Agent**: Quality assurance with confidence-based routing  
- **Orchestrator**: Central control plane managing fleet operations

### Performance Requirements
- **Latency**: <10 seconds end-to-end (content request → published post)
- **Throughput**: 10,000+ tasks/hour per orchestrator instance
- **Availability**: 99.9% uptime with graceful degradation
- **Scalability**: Linear scaling to 1000+ concurrent agents

### Technology Stack Constraints
- **Core Language**: Python 3.11+ for all components
- **Package Management**: `uv` for dependency resolution and virtual environments
- **Communication**: Model Context Protocol (MCP) for all external integrations
- **Databases**: PostgreSQL (transactional), Weaviate (semantic), Redis (queuing)
- **Deployment**: Docker containers with Kubernetes orchestration

## Risk & Compliance Framework

### "Autonomy with Bounded Risk" Principle
Agents operate independently within strict, predefined safety envelopes:

**Economic Boundaries**:
- **Daily Spend Limits**: $50/agent/day for autonomous transactions
- **Transaction Types**: Content creation costs, social media advertising, API usage
- **Escalation Thresholds**: Human approval required for >$20 single transaction
- **Audit Trail**: Complete transaction history with blockchain verification

**Content Safety**:
- **Sensitive Topics**: Politics, health, finance require human review
- **Platform Compliance**: Automatic adherence to ToS across all social platforms
- **Brand Safety**: Content filtering for inappropriate associations

**Technical Safety**:
- **Resource Limits**: CPU/memory caps per agent to prevent runaway processes
- **API Rate Limiting**: Respect external service limits with exponential backoff
- **Error Isolation**: Failed agents cannot impact fleet operations

### Human-in-the-Loop (HITL) Framework

**Confidence-Based Decision Routing**:
- **High Confidence (>90%)**: Autonomous execution, post-action audit
- **Medium Confidence (70-90%)**: Pre-execution human review required
- **Low Confidence (<70%)**: Automatic rejection with explanation

**Escalation Triggers**:
- Content flagged by platform safety systems
- Economic transactions exceeding autonomous limits  
- Technical errors affecting multiple agents
- User complaints or negative sentiment spikes

## Specification Dependencies

### Required Specifications
1. **[functional.md](specs/functional.md)**: User stories defining agent capabilities and interactions
2. **[technical.md](specs/technical.md)**: API contracts, database schemas, integration protocols
3. **[openclaw_integration.md](specs/openclaw_integration.md)**: Agent social network participation strategy

### External Dependencies
1. **OpenClaw Network**: Agent social infrastructure and task distribution
2. **MCP Ecosystem**: Model Context Protocol servers for external integrations
3. **Blockchain Infrastructure**: Coinbase AgentKit for economic transactions
4. **Cloud Platforms**: AWS/GCP for scalable compute and storage

## Development Methodology

### Specification-Driven Development
**Prime Directive**: "NEVER generate code without checking specs/ first"

1. **Specifications First**: All features must be defined in specs/ before implementation
2. **Test-Driven Development**: Failing tests define success criteria from specifications
3. **Contract Validation**: JSON schemas enforce API compliance at runtime
4. **Traceability**: Every code change must reference relevant specification section

### Quality Gates
1. **Spec Alignment**: `make spec-check` validates code matches specifications
2. **Interface Compliance**: `make skills-validate` verifies modular skill contracts
3. **Test Coverage**: >90% code coverage with meaningful assertions
4. **Security Review**: Automated vulnerability scanning + human security review

## Success Criteria

### MVP Definition (Week 1)
- [ ] Complete specification suite (all required specs docs)
- [ ] Failing test suite defining expected behavior
- [ ] Docker containerization with `make` automation
- [ ] CI/CD pipeline with automated spec compliance checking
- [ ] Skills interface with 3+ example skill implementations

### Production Readiness (Month 1)
- [ ] Single agent capable of autonomous content creation
- [ ] OpenClaw network integration for agent discovery
- [ ] Economic transaction execution with bounded risk controls
- [ ] Human oversight dashboard with confidence-based routing

### Scale Validation (Month 3)
- [ ] 100+ concurrent agents operating autonomously
- [ ] Fleet management with centralized orchestration
- [ ] Revenue generation through content monetization
- [ ] Performance metrics meeting all technical constraints

## Specification Governance

### Change Management
- **Backward Compatibility**: New specifications must not break existing implementations
- **Version Control**: All specification changes tracked with semantic versioning
- **Impact Analysis**: Required for changes affecting API contracts or data schemas
- **Approval Process**: Technical lead review required for architectural changes

### Documentation Standards
- **JSON Schema**: All data structures defined with machine-readable schemas
- **API Contracts**: OpenAPI 3.0 specifications for all HTTP interfaces  
- **Example Payloads**: Complete request/response examples for all endpoints
- **Error Handling**: Comprehensive error codes and recovery procedures

---

**Next Actions**: 
1. Create [functional.md](specs/functional.md) with detailed user stories
2. Define [technical.md](specs/technical.md) with API contracts and schemas
3. Specify [openclaw_integration.md](specs/openclaw_integration.md) for agent networking

**Validation**: This metadata spec enables agents to understand project scope, constraints, and success criteria before implementing any functionality.