# Project Chimera - MCP Tooling Strategy

**Document**: `research/tooling_strategy.md`  
**Version**: 1.0.0  
**Last Updated**: February 5, 2026  
**Dependencies**: [specs/technical.md](../specs/technical.md), [CLAUDE.md](../CLAUDE.md)

## Overview

This document defines the Model Context Protocol (MCP) server strategy for Project Chimera development and runtime operations. MCP servers act as standardized bridges between our agents and external systems, following the principle that "MCP is the USB-C for AI applications."

**Two Categories of MCP Servers**:
1. **Development MCP Servers**: Tools that help developers build and maintain the system
2. **Runtime MCP Servers**: Production integrations that agents use during autonomous operations

## Development MCP Servers

### Primary Development MCPs

#### 1. git-mcp (Version Control Operations)
**Purpose**: Enable AI assistants to perform Git operations during development
**Installation**: 
```bash
uv add mcp-server-git
```

**Configuration**: `.vscode/settings.json`
```json
{
  "mcp.servers": {
    "git-mcp": {
      "command": "uv",
      "args": ["run", "mcp-server-git"],
      "env": {
        "GIT_REPOSITORY_PATH": "/workspace"
      }
    }
  }
}
```

**Capabilities**:
- **Resources**: 
  - `git://status` - Current repository status
  - `git://log/{branch}` - Commit history
  - `git://diff` - Working directory changes
  
- **Tools**:
  - `git_commit` - Stage and commit changes with message
  - `git_branch` - Create, list, or switch branches  
  - `git_merge` - Merge branches with conflict resolution
  - `git_push` - Push commits to remote repository
  - `git_pull` - Pull latest changes from remote

**Use Cases**:
- Automated commit message generation based on code changes
- Branch management for feature development
- Code review and diff analysis
- Repository health monitoring

#### 2. filesystem-mcp (File System Operations)
**Purpose**: Safe file system operations with sandboxing for AI agents
**Installation**:
```bash
uv add mcp-server-filesystem
```

**Configuration**:
```json
{
  "mcp.servers": {
    "filesystem-mcp": {
      "command": "uv", 
      "args": ["run", "mcp-server-filesystem"],
      "env": {
        "ALLOWED_PATHS": "/workspace/chimera,/workspace/skills,/workspace/specs",
        "READ_ONLY_PATHS": "/workspace/specs",
        "FORBIDDEN_EXTENSIONS": ".env,.key,.pem"
      }
    }
  }
}
```

**Capabilities**:
- **Resources**:
  - `file://{path}` - Read file contents
  - `directory://{path}` - List directory contents
  - `tree://{path}` - Recursive directory tree
  
- **Tools**:
  - `create_file` - Create new files with content validation
  - `edit_file` - Modify existing files with backup
  - `delete_file` - Safe file deletion with confirmation
  - `move_file` - Rename/move files with conflict handling
  - `search_files` - Content search across file system

**Security Features**:
- Sandboxed to project directories only
- Read-only access to specs/ directory (source of truth)
- File extension blacklisting for sensitive files
- Automatic backup of modified files

#### 3. postgres-mcp (Database Development)  
**Purpose**: Database schema management, migrations, and development queries
**Installation**:
```bash
uv add mcp-server-postgres
```

**Configuration**:
```json
{
  "mcp.servers": {
    "postgres-mcp": {
      "command": "uv",
      "args": ["run", "mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://chimera_dev:password@localhost:5432/chimera_dev",
        "ALLOWED_OPERATIONS": "SELECT,INSERT,UPDATE,CREATE,ALTER,DROP",
        "FORBIDDEN_TABLES": "users.password_hash"
      }
    }
  }
}
```

**Capabilities**:
- **Resources**:
  - `db://schema/{table}` - Table structure and constraints
  - `db://data/{table}` - Sample data for testing
  - `db://metrics` - Database performance metrics
  
- **Tools**:
  - `execute_query` - Run SQL queries with result validation
  - `create_migration` - Generate Alembic migration files
  - `apply_migration` - Execute database migrations
  - `backup_data` - Create development data backups

**Safety Features**:
- Read-only mode for production databases
- Query complexity limits (joins, subqueries)
- Row count limits for SELECT operations
- Automatic transaction rollback on errors

### Secondary Development MCPs

#### 4. python-mcp (Code Analysis & Testing)
**Purpose**: Python code analysis, linting, and test execution
**Capabilities**:
- **Tools**:
  - `run_tests` - Execute pytest with coverage reporting
  - `lint_code` - Run flake8, black, isort on codebase
  - `analyze_dependencies` - Check for security vulnerabilities
  - `generate_docs` - Auto-generate API documentation

#### 5. docker-mcp (Container Management)
**Purpose**: Docker container and image management for development
**Capabilities**:
- **Tools**:
  - `build_image` - Build Docker images with caching
  - `run_container` - Start containers with port mapping
  - `container_logs` - Stream container logs for debugging
  - `cleanup_resources` - Remove unused containers/images

## Runtime MCP Servers (Production)

### Social Media Integration MCPs

#### 1. twitter-mcp (Twitter/X API Integration)
**Purpose**: Social media posting, mentions monitoring, engagement tracking
**Configuration**:
```json
{
  "mcp.servers": {
    "twitter-mcp": {
      "command": "uv",
      "args": ["run", "mcp-server-twitter"],
      "env": {
        "TWITTER_API_KEY": "${TWITTER_API_KEY}",
        "TWITTER_API_SECRET": "${TWITTER_API_SECRET}",
        "RATE_LIMIT_BUFFER": "0.8"
      }
    }
  }
}
```

**Capabilities**:
- **Resources**:
  - `twitter://mentions/{handle}/recent` - Recent mentions and replies
  - `twitter://trends/global` - Trending topics worldwide
  - `twitter://analytics/{tweet_id}` - Tweet performance metrics
  
- **Tools**:
  - `post_tweet` - Publish tweets with media attachments
  - `reply_to_tweet` - Respond to mentions and comments
  - `schedule_tweet` - Queue tweets for optimal timing
  - `analyze_engagement` - Track likes, retweets, replies

#### 2. instagram-mcp (Instagram API Integration)  
**Purpose**: Visual content publishing, story management, engagement tracking
**Capabilities**:
- **Resources**:
  - `instagram://feed/{handle}` - Recent posts and performance
  - `instagram://stories/{handle}` - Active stories metrics
  
- **Tools**:
  - `post_image` - Publish photos with captions and hashtags
  - `post_video` - Share video content with optimization
  - `create_story` - Temporary story content publishing

#### 3. tiktok-mcp (TikTok API Integration)
**Purpose**: Short-form video content publishing and trend analysis
**Capabilities**:
- **Resources**:
  - `tiktok://trends/hashtags` - Trending hashtags and challenges
  - `tiktok://analytics/{video_id}` - Video performance metrics
  
- **Tools**:
  - `upload_video` - Publish TikTok videos with effects
  - `analyze_trends` - Identify viral content opportunities

### Economic Integration MCPs

#### 4. coinbase-mcp (Blockchain Transactions)
**Purpose**: Crypto wallet management, transactions, DeFi interactions
**Installation**:
```bash
uv add coinbase-agentkit-mcp
```

**Configuration**:
```json
{
  "mcp.servers": {
    "coinbase-mcp": {
      "command": "uv",
      "args": ["run", "coinbase-agentkit-mcp"],
      "env": {
        "COINBASE_API_KEY": "${COINBASE_API_KEY}",
        "COINBASE_PRIVATE_KEY": "${COINBASE_PRIVATE_KEY}",
        "NETWORK": "base",
        "DAILY_SPEND_LIMIT": "50.0"
      }
    }
  }
}
```

**Capabilities**:
- **Resources**:
  - `wallet://balance/{address}` - Current wallet balances
  - `blockchain://transactions/{address}` - Transaction history
  - `defi://protocols/base` - Available DeFi protocols on Base
  
- **Tools**:
  - `send_payment` - Transfer cryptocurrency between wallets
  - `deploy_token` - Create new ERC-20 tokens
  - `stake_tokens` - Participate in DeFi staking protocols
  - `swap_tokens` - Exchange tokens via DEX protocols

**Security Controls**:
- Daily spending limits per persona ($50 USD)
- Single transaction limits ($20 USD)
- Multi-signature requirement for large transactions
- Human approval workflows for sensitive operations

### Data & Intelligence MCPs

#### 5. weaviate-mcp (Vector Database)  
**Purpose**: Semantic memory storage, RAG operations, persona memory management
**Configuration**:
```json
{
  "mcp.servers": {
    "weaviate-mcp": {
      "command": "uv",
      "args": ["run", "mcp-server-weaviate"],
      "env": {
        "WEAVIATE_URL": "http://localhost:8080",
        "WEAVIATE_API_KEY": "${WEAVIATE_API_KEY}",
        "DEFAULT_VECTORIZER": "text2vec-openai"
      }
    }
  }
}
```

**Capabilities**:
- **Resources**:
  - `memory://persona/{persona_id}` - Agent memory and context
  - `knowledge://trends/recent` - Recent trend analysis data  
  - `content://similar/{content_id}` - Similar content recommendations
  
- **Tools**:
  - `store_memory` - Save agent experiences and learnings
  - `semantic_search` - Find relevant memories by meaning
  - `update_persona` - Modify agent personality over time
  - `analyze_patterns` - Identify behavioral patterns

#### 6. news-mcp (News & Information)
**Purpose**: Real-time news aggregation, sentiment analysis, trend detection
**Capabilities**:
- **Resources**:
  - `news://technology/latest` - Latest tech news articles
  - `news://trending/topics` - Trending news topics globally
  - `sentiment://market/{keyword}` - Market sentiment analysis
  
- **Tools**:
  - `fetch_articles` - Retrieve news articles by topic/keyword
  - `analyze_sentiment` - Perform sentiment analysis on content
  - `detect_trends` - Identify emerging news trends

## MCP Server Management

### Development Workflow
1. **Local Development**: Use development MCPs (git, filesystem, postgres)
2. **Testing**: Validate MCP integrations with mock data
3. **Staging**: Deploy runtime MCPs in isolated test environment  
4. **Production**: Full MCP server suite with monitoring and failover

### Security & Compliance
```python
# MCP Security Configuration
MCP_SECURITY_CONFIG = {
    "authentication": {
        "require_api_keys": True,
        "token_rotation_hours": 24,
        "rate_limiting": True
    },
    "authorization": {
        "role_based_access": True,
        "resource_permissions": "restrictive",
        "audit_logging": True
    },
    "data_protection": {
        "encrypt_in_transit": True,
        "encrypt_at_rest": True,
        "data_retention_days": 90
    }
}
```

### Monitoring & Observability  
- **Metrics Collection**: Response times, error rates, usage patterns
- **Health Checks**: Automated MCP server availability monitoring
- **Alerting**: Slack/email notifications for MCP server failures
- **Logging**: Structured logs for debugging and compliance

### Disaster Recovery
- **Failover**: Backup MCP servers for critical integrations
- **Circuit Breakers**: Automatic fallback when MCP servers are unavailable  
- **Data Backup**: Regular backups of MCP server configurations
- **Recovery Testing**: Monthly disaster recovery drills

## Implementation Roadmap

### Phase 1: Development MCPs (Week 1)
- [ ] Deploy git-mcp for version control automation
- [ ] Configure filesystem-mcp with proper sandboxing
- [ ] Set up postgres-mcp for database development
- [ ] Test integration with VS Code and Claude

### Phase 2: Core Runtime MCPs (Week 2)
- [ ] Deploy twitter-mcp for social media automation
- [ ] Configure coinbase-mcp for economic transactions
- [ ] Set up weaviate-mcp for semantic memory
- [ ] Implement security controls and rate limiting

### Phase 3: Extended Runtime MCPs (Week 3)
- [ ] Deploy instagram-mcp and tiktok-mcp 
- [ ] Configure news-mcp for market intelligence
- [ ] Set up monitoring and alerting systems
- [ ] Conduct end-to-end integration testing

### Phase 4: Production Optimization (Week 4)
- [ ] Performance tuning and optimization
- [ ] Security audit and penetration testing
- [ ] Disaster recovery implementation
- [ ] Documentation and training materials

---

**Integration Notes**:
- All MCP servers must follow the Model Context Protocol specification
- Resource URIs use standardized naming conventions (`protocol://path/resource`)
- Tool interfaces include input validation and error handling
- Configuration supports environment-specific overrides
- Security follows principle of least privilege with audit trails

**Next Steps**: Implement development MCP servers first to accelerate agent-assisted development, then gradually deploy runtime MCPs for production agent operations.