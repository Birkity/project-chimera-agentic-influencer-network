# Project Chimera 🔥

**Autonomous AI Influencer Network with Economic Agency**

Project Chimera is an advanced autonomous AI system designed to create, manage, and monetize AI-powered influencers across multiple platforms. Built on the FastRender Swarm Pattern, it enables persistent, goal-directed digital entities capable of autonomous content creation, real-time trend analysis, and economic transactions.

## 🎯 Core Capabilities

- **Autonomous Content Generation**: Multi-platform content creation (Twitter, Instagram, TikTok)
- **Real-time Trend Analysis**: Market intelligence and responsive content strategy
- **Economic Agency**: Crypto wallet management with bounded-risk transactions
- **Agent Social Network**: OpenClaw integration for agent-to-agent communication
- **Scalable Architecture**: Support for 1000+ concurrent autonomous agents

## 🏗️ Architecture

### FastRender Swarm Pattern
- **Planner Agent**: Strategic task decomposition and goal planning
- **Worker Pool**: Parallel execution of atomic tasks with stateless agents  
- **Judge Agent**: Quality assurance with confidence-based HITL routing
- **Orchestrator**: Central control plane for fleet management

### Confidence-Based Human-in-the-Loop
- **High Confidence (>90%)**: Autonomous execution
- **Medium Confidence (70-90%)**: Human review required
- **Low Confidence (<70%)**: Automatic rejection with escalation

## 🚀 Quick Start

### Prerequisites
- Python 3.11+ 
- [uv](https://docs.astral.sh/uv/) for dependency management
- Docker for containerized development
- Redis for task queuing
- PostgreSQL for persistent storage

### Installation

```bash
# Clone the repository
git clone https://github.com/chimera-ai/project-chimera.git
cd project-chimera

# Setup environment with uv
make setup

# Run tests to verify installation
make test

# Start development environment  
make dev
```

### Development Commands

```bash
# Setup project dependencies
make setup

# Run all tests (should fail initially - TDD approach)
make test

# Validate specs compliance
make spec-check

# Validate skills interface
make skills-validate

# Start local development server
make dev

# Build Docker container
make build

# Clean environment
make clean
```

## 📁 Project Structure

```
project-chimera/
├── specs/                  # Master specifications
│   ├── _meta.md           # High-level vision and constraints
│   ├── functional.md      # User stories and requirements
│   ├── technical.md       # API contracts and schemas
│   └── openclaw_integration.md # Agent network protocol
├── chimera/               # Core Python package
│   ├── agents/           # Agent implementations
│   ├── orchestrator/     # Fleet management
│   ├── api/             # FastAPI endpoints
│   └── models/          # Data models and schemas
├── skills/               # Agent skills modules
│   ├── content_creation/ # Video, audio, caption generation
│   ├── market_intelligence/ # Trend analysis, news fetching
│   └── social_engagement/ # Comments, scheduling, metrics
├── tests/               # Test-driven development
│   ├── test_trend_fetcher.py
│   ├── test_skills_interface.py
│   └── integration/
├── research/            # Documentation and analysis
├── .cursor/            # IDE AI context rules
├── .github/workflows/  # CI/CD automation
└── Makefile           # Development commands
```

## 🎨 Skills Architecture

### Content Creation Pipeline
- `skill_download_video`: Video acquisition and processing
- `skill_transcribe_audio`: Speech-to-text conversion
- `skill_generate_caption`: Social media content creation

### Market Intelligence
- `skill_analyze_trends`: Pattern recognition in social data
- `skill_fetch_news`: Real-time news and information gathering  
- `skill_sentiment_analysis`: Emotion and opinion analysis

### Social Engagement
- `skill_reply_comments`: Automated comment responses
- `skill_schedule_posts`: Content timing optimization
- `skill_analyze_metrics`: Performance measurement and insights

## 🔗 MCP Integration

Project Chimera uses Model Context Protocol (MCP) for all external integrations:

### Development MCP Servers
- `git-mcp`: Version control operations
- `filesystem-mcp`: File system management
- `postgres-mcp`: Database operations

### Production MCP Servers  
- `twitter-mcp`: Social media API integration
- `coinbase-mcp`: Blockchain transaction management
- `weaviate-mcp`: Vector database operations

## 🌐 OpenClaw Network Integration

Chimera agents participate in the OpenClaw social network through:
- **SOUL.md Persona Definition**: Agent personality and capability publishing
- **Heartbeat Protocol**: Availability and status broadcasting
- **Task Assignment Network**: Cross-agent collaboration
- **Secure credential management**: Distributed trust model

## 💰 Economic Agency (Bounded Risk)

### Autonomy Principles
- **Predefined Spending Envelopes**: Strict daily/weekly limits per agent
- **Automatic Escalation**: Transactions outside bounds require human approval
- **Multi-signature Security**: Enterprise-grade key management
- **Audit Trail**: Complete transaction history and compliance

### Transaction Types
- Content creation costs (AI model usage, media licensing)
- Social media promotion and advertising
- Cross-platform engagement incentives
- Agent-to-agent economic interactions

## 🧪 Test-Driven Development

This repository follows TDD principles:
- **Specification-First**: All code must align with `specs/` directory
- **Failing Tests Define Success**: Tests fail until correct implementation
- **Contract Validation**: JSON schemas enforce API compliance
- **Continuous Integration**: Automated testing on every commit

## 🔒 Security & Governance

### AI Code Review
- **CodeRabbit Integration**: Automated specification alignment checking
- **Security Scanning**: Vulnerability detection in dependencies
- **Performance Monitoring**: Latency and throughput optimization

### Human Oversight
- **Confidence-based routing**: AI uncertainty triggers human review
- **Sensitive topic flags**: Politics, health, finance require approval
- **Economic transaction limits**: Spending caps with escalation protocols

## 🤝 Contributing

1. Read the specifications in `specs/` directory
2. Check `.cursor/rules` for AI assistant context
3. Write failing tests first (TDD approach)
4. Implement features to make tests pass  
5. Ensure `make spec-check` passes
6. Submit PR with CodeRabbit review

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🎖️ Challenge Context

This repository was developed as part of the **10 Academy AI Engineering Challenge**. It demonstrates:
- Industry-standard repository structure and tooling
- Specification-driven development methodology
- Modern AI development practices with MCP integration
- Test-driven development for AI systems
- Containerized deployment and CI/CD automation

**Assessment Criteria**: Spec Fidelity, Tooling Strategy, Testing Approach, CI/CD Governance

---

*Built with ❤️ by the Chimera AI Team*