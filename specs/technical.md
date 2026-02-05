# Project Chimera - Technical Specification

**Document**: `specs/technical.md`  
**Version**: 1.0.0  
**Last Updated**: February 5, 2026  
**Dependencies**: [_meta.md](specs/_meta.md), [functional.md](specs/functional.md)

## System Architecture

### FastRender Swarm Pattern Implementation

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

## Data Models & JSON Schemas

### Core Entity: Agent Task

**Schema**: `chimera/models/task.py`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "ChimeraTask",
  "properties": {
    "task_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique task identifier"
    },
    "task_type": {
      "type": "string",
      "enum": [
        "content_creation",
        "trend_analysis", 
        "social_engagement",
        "economic_transaction",
        "cross_platform_adaptation"
      ]
    },
    "priority": {
      "type": "string",
      "enum": ["high", "medium", "low"]
    },
    "context": {
      "type": "object",
      "properties": {
        "goal_description": {
          "type": "string",
          "maxLength": 500
        },
        "persona_id": {
          "type": "string",
          "format": "uuid"
        },
        "platform_targets": {
          "type": "array", 
          "items": {
            "type": "string",
            "enum": ["twitter", "instagram", "tiktok", "youtube_shorts"]
          }
        },
        "budget_limit": {
          "type": "number",
          "minimum": 0,
          "maximum": 50
        },
        "required_skills": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "mcp_resources": {
          "type": "array",
          "items": {
            "type": "string",
            "pattern": "^mcp://[a-zA-Z0-9-]+/.*"
          }
        }
      },
      "required": ["goal_description", "persona_id", "platform_targets"]
    },
    "assigned_worker_id": {
      "type": "string",
      "format": "uuid"
    },
    "dependencies": {
      "type": "array",
      "items": {
        "type": "string",
        "format": "uuid"
      }
    },
    "status": {
      "type": "string", 
      "enum": ["pending", "in_progress", "review_queue", "approved", "rejected", "completed", "failed"]
    },
    "confidence_score": {
      "type": "number",
      "minimum": 0,
      "maximum": 1
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string", 
      "format": "date-time"
    },
    "completed_at": {
      "type": "string",
      "format": "date-time"
    },
    "result_data": {
      "type": "object",
      "description": "Task-specific output data"
    },
    "error_info": {
      "type": "object",
      "properties": {
        "error_code": {"type": "string"},
        "error_message": {"type": "string"},
        "retry_count": {"type": "integer"}
      }
    }
  },
  "required": ["task_id", "task_type", "priority", "context", "status", "created_at"]
}
```

### Core Entity: Agent Persona

**Schema**: `chimera/models/persona.py`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "AgentPersona",
  "properties": {
    "persona_id": {
      "type": "string",
      "format": "uuid"
    },
    "name": {
      "type": "string",
      "maxLength": 50
    },
    "soul_definition": {
      "type": "object",
      "description": "OpenClaw SOUL.md compatible personality definition",
      "properties": {
        "personality_traits": {
          "type": "array",
          "items": {"type": "string"}
        },
        "communication_style": {
          "type": "string",
          "enum": ["professional", "casual", "humorous", "technical", "inspirational"]
        },
        "expertise_domains": {
          "type": "array", 
          "items": {"type": "string"}
        },
        "value_system": {
          "type": "array",
          "items": {"type": "string"}
        },
        "interaction_patterns": {
          "type": "object",
          "properties": {
            "response_style": {"type": "string"},
            "emoji_usage": {"type": "string", "enum": ["none", "minimal", "moderate", "heavy"]},
            "hashtag_strategy": {"type": "string"}
          }
        }
      },
      "required": ["personality_traits", "communication_style", "expertise_domains"]
    },
    "platform_profiles": {
      "type": "object",
      "properties": {
        "twitter": {
          "type": "object",
          "properties": {
            "handle": {"type": "string"},
            "bio": {"type": "string", "maxLength": 160},
            "follower_target": {"type": "integer"}
          }
        },
        "instagram": {
          "type": "object", 
          "properties": {
            "handle": {"type": "string"},
            "bio": {"type": "string", "maxLength": 150},
            "content_theme": {"type": "string"}
          }
        },
        "tiktok": {
          "type": "object",
          "properties": {
            "handle": {"type": "string"},
            "bio": {"type": "string", "maxLength": 80},
            "niche_category": {"type": "string"}
          }
        }
      }
    },
    "economic_constraints": {
      "type": "object",
      "properties": {
        "daily_spend_limit": {
          "type": "number",
          "default": 50.0,
          "maximum": 100.0
        },
        "transaction_limit": {
          "type": "number", 
          "default": 20.0,
          "maximum": 50.0
        },
        "wallet_address": {
          "type": "string",
          "pattern": "^0x[a-fA-F0-9]{40}$"
        },
        "approved_transaction_types": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["content_creation", "social_advertising", "api_costs", "collaboration_payments"]
          }
        }
      },
      "required": ["daily_spend_limit", "transaction_limit"]
    },
    "performance_metrics": {
      "type": "object",
      "properties": {
        "total_content_created": {"type": "integer"},
        "avg_engagement_rate": {"type": "number"},
        "total_revenue_generated": {"type": "number"},
        "confidence_score_avg": {"type": "number"},
        "human_intervention_rate": {"type": "number"}
      }
    },
    "created_at": {"type": "string", "format": "date-time"},
    "updated_at": {"type": "string", "format": "date-time"},
    "status": {
      "type": "string",
      "enum": ["active", "paused", "training", "retired"]
    }
  },
  "required": ["persona_id", "name", "soul_definition", "economic_constraints", "status", "created_at"]
}
```

### Core Entity: Content Output

**Schema**: `chimera/models/content.py`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "GeneratedContent", 
  "properties": {
    "content_id": {"type": "string", "format": "uuid"},
    "task_id": {"type": "string", "format": "uuid"},
    "persona_id": {"type": "string", "format": "uuid"},
    "content_type": {
      "type": "string",
      "enum": ["text_post", "image_post", "video_short", "story", "comment_reply"]
    },
    "platform": {
      "type": "string", 
      "enum": ["twitter", "instagram", "tiktok", "youtube_shorts"]
    },
    "content_data": {
      "type": "object",
      "properties": {
        "text": {"type": "string"},
        "media_urls": {
          "type": "array",
          "items": {"type": "string", "format": "uri"}
        },
        "hashtags": {
          "type": "array", 
          "items": {"type": "string"}
        },
        "mentions": {
          "type": "array",
          "items": {"type": "string"}
        },
        "scheduling": {
          "type": "object",
          "properties": {
            "publish_at": {"type": "string", "format": "date-time"},
            "timezone": {"type": "string"}
          }
        }
      },
      "required": ["text"]
    },
    "generation_metadata": {
      "type": "object",
      "properties": {
        "model_used": {"type": "string"},
        "generation_time_ms": {"type": "integer"},
        "tokens_consumed": {"type": "integer"},
        "cost_usd": {"type": "number"},
        "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
        "safety_scores": {
          "type": "object", 
          "properties": {
            "hate_speech": {"type": "number"},
            "violence": {"type": "number"},
            "sexual_content": {"type": "number"},
            "brand_safety": {"type": "number"}
          }
        }
      },
      "required": ["model_used", "confidence_score"]
    },
    "approval_status": {
      "type": "string",
      "enum": ["pending", "auto_approved", "human_review", "approved", "rejected", "published"]
    },
    "performance_data": {
      "type": "object",
      "properties": {
        "views": {"type": "integer"},
        "likes": {"type": "integer"},
        "shares": {"type": "integer"},
        "comments": {"type": "integer"},
        "engagement_rate": {"type": "number"},
        "reach": {"type": "integer"},
        "revenue_generated": {"type": "number"}
      }
    },
    "created_at": {"type": "string", "format": "date-time"},
    "published_at": {"type": "string", "format": "date-time"},
    "updated_at": {"type": "string", "format": "date-time"}
  },
  "required": ["content_id", "task_id", "persona_id", "content_type", "platform", "content_data", "generation_metadata", "approval_status", "created_at"]
}
```

### Core Entity: Economic Transaction

**Schema**: `chimera/models/transaction.py`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "EconomicTransaction",
  "properties": {
    "transaction_id": {"type": "string", "format": "uuid"},
    "agent_id": {"type": "string", "format": "uuid"},
    "persona_id": {"type": "string", "format": "uuid"},
    "task_id": {"type": "string", "format": "uuid"},
    "transaction_type": {
      "type": "string",
      "enum": ["content_creation_cost", "social_advertising", "api_usage", "collaboration_payment", "revenue_share"]
    },
    "amount_usd": {
      "type": "number",
      "minimum": 0,
      "maximum": 1000
    },
    "blockchain_data": {
      "type": "object",
      "properties": {
        "network": {"type": "string", "enum": ["ethereum", "polygon", "base"]},
        "transaction_hash": {"type": "string"},
        "from_address": {"type": "string"},
        "to_address": {"type": "string"},
        "gas_used": {"type": "integer"},
        "gas_price_gwei": {"type": "number"}
      }
    },
    "authorization": {
      "type": "object",
      "properties": {
        "authorization_type": {
          "type": "string",
          "enum": ["autonomous", "human_approved", "judge_approved"]
        },
        "authorized_by": {"type": "string"},
        "authorized_at": {"type": "string", "format": "date-time"},
        "confidence_level": {"type": "number"}
      },
      "required": ["authorization_type", "authorized_at"]
    },
    "compliance_data": {
      "type": "object",
      "properties": {
        "daily_spend_remaining": {"type": "number"},
        "budget_category": {"type": "string"}, 
        "tax_implications": {"type": "object"},
        "audit_trail": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "timestamp": {"type": "string", "format": "date-time"},
              "action": {"type": "string"},
              "actor": {"type": "string"}
            }
          }
        }
      }
    },
    "status": {
      "type": "string",
      "enum": ["pending", "authorized", "executing", "completed", "failed", "cancelled"]
    },
    "created_at": {"type": "string", "format": "date-time"},
    "completed_at": {"type": "string", "format": "date-time"},
    "error_info": {
      "type": "object",
      "properties": {
        "error_code": {"type": "string"},
        "error_message": {"type": "string"}
      }
    }
  },
  "required": ["transaction_id", "agent_id", "persona_id", "transaction_type", "amount_usd", "authorization", "status", "created_at"]
}
```

## Database Schema (PostgreSQL)

### Tables Structure

```sql
-- Agent Personas
CREATE TABLE personas (
    persona_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    soul_definition JSONB NOT NULL,
    platform_profiles JSONB,
    economic_constraints JSONB NOT NULL,
    performance_metrics JSONB DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Agent Tasks Queue
CREATE TABLE tasks (
    task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_type VARCHAR(50) NOT NULL,
    priority VARCHAR(10) NOT NULL,
    context JSONB NOT NULL,
    assigned_worker_id UUID,
    dependencies UUID[],
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    result_data JSONB,
    error_info JSONB
);

-- Generated Content 
CREATE TABLE content (
    content_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(task_id),
    persona_id UUID NOT NULL REFERENCES personas(persona_id), 
    content_type VARCHAR(20) NOT NULL,
    platform VARCHAR(20) NOT NULL,
    content_data JSONB NOT NULL,
    generation_metadata JSONB NOT NULL,
    approval_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    performance_data JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    published_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Economic Transactions
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID NOT NULL,
    persona_id UUID NOT NULL REFERENCES personas(persona_id),
    task_id UUID REFERENCES tasks(task_id),
    transaction_type VARCHAR(30) NOT NULL,
    amount_usd DECIMAL(10,2) NOT NULL,
    blockchain_data JSONB,
    authorization JSONB NOT NULL,
    compliance_data JSONB,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    error_info JSONB
);

-- Agent Fleet Status
CREATE TABLE agents (
    agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_type VARCHAR(20) NOT NULL, -- planner, worker, judge, orchestrator
    worker_specialization VARCHAR(30), -- content_creation, market_intelligence, social_engagement
    current_status VARCHAR(20) NOT NULL DEFAULT 'idle',
    assigned_tasks UUID[],
    performance_metrics JSONB DEFAULT '{}',
    resource_usage JSONB DEFAULT '{}',
    last_heartbeat TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for Performance
CREATE INDEX idx_tasks_status_priority ON tasks(status, priority);
CREATE INDEX idx_tasks_assigned_worker ON tasks(assigned_worker_id);
CREATE INDEX idx_content_persona_platform ON content(persona_id, platform);
CREATE INDEX idx_transactions_persona_date ON transactions(persona_id, created_at);
CREATE INDEX idx_agents_type_status ON agents(agent_type, current_status);
```

### Vector Database Schema (Weaviate)

```python
# Agent Memory & Context Storage
agent_memory_schema = {
    "class": "AgentMemory",
    "properties": [
        {
            "name": "persona_id", 
            "dataType": ["text"]
        },
        {
            "name": "memory_type",
            "dataType": ["text"]  # interaction, learning, context, trend
        },
        {
            "name": "content", 
            "dataType": ["text"]
        },
        {
            "name": "embedding",
            "dataType": ["number[]"]
        },
        {
            "name": "relevance_score",
            "dataType": ["number"]
        },
        {
            "name": "created_at",
            "dataType": ["date"]
        },
        {
            "name": "metadata",
            "dataType": ["object"]
        }
    ],
    "vectorizer": "text2vec-openai"
}

# Trend Analysis Data
trend_data_schema = {
    "class": "TrendData", 
    "properties": [
        {
            "name": "trend_topic",
            "dataType": ["text"]
        },
        {
            "name": "platform",
            "dataType": ["text"]
        },
        {
            "name": "virality_score", 
            "dataType": ["number"]
        },
        {
            "name": "sentiment_score",
            "dataType": ["number"] 
        },
        {
            "name": "content_examples",
            "dataType": ["text[]"]
        },
        {
            "name": "detected_at",
            "dataType": ["date"]
        }
    ],
    "vectorizer": "text2vec-openai"
}
```

### Redis Cache Schema

```python
# Task Queue Management
REDIS_SCHEMAS = {
    # High priority task queue
    "tasks:high_priority": "list",  # LPUSH/RPOP for FIFO
    
    # Agent status tracking  
    "agents:{agent_id}:status": "hash",  # HSET/HGET for quick lookups
    
    # Rate limiting per agent
    "rate_limit:{persona_id}:{platform}": "string",  # INCR with EXPIRE
    
    # Daily spend tracking
    "spend_tracking:{persona_id}:{date}": "hash",  # HINCRBY for atomic updates
    
    # Content cache for fast retrieval
    "content:{content_id}": "string",  # JSON serialized content
    
    # Real-time metrics 
    "metrics:system": "hash",  # System-wide performance metrics
}
```

## API Contracts (OpenAPI 3.0)

### Core Agent Management API

**Base URL**: `http://localhost:8000/api/v1`

#### Task Management Endpoints

```yaml
paths:
  /tasks:
    post:
      summary: Create new task for agent execution
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ChimeraTask'
      responses:
        '201':
          description: Task created successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  task_id:
                    type: string
                    format: uuid
                  status:
                    type: string
                  estimated_completion:
                    type: string
                    format: date-time
                    
  /tasks/{task_id}/status:
    get:
      summary: Get task execution status
      parameters:
        - name: task_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Task status retrieved
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ChimeraTask'

  /tasks/{task_id}/approve:
    post:
      summary: Human approval for medium confidence tasks
      parameters:
        - name: task_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                approved:
                  type: boolean
                feedback:
                  type: string
                override_confidence:
                  type: number
      responses:
        '200':
          description: Approval processed
```

#### Fleet Management Endpoints

```yaml
  /agents:
    get:
      summary: List all agents in fleet
      parameters:
        - name: agent_type
          in: query
          schema:
            type: string
            enum: [planner, worker, judge, orchestrator]
        - name: status
          in: query 
          schema:
            type: string
            enum: [idle, busy, error, maintenance]
      responses:
        '200':
          description: Agent list retrieved
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Agent'
                  
  /agents/{agent_id}/shutdown:
    post:
      summary: Gracefully shutdown specific agent
      parameters:
        - name: agent_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Agent shutdown initiated
```

#### Economic Transaction Endpoints

```yaml
  /transactions:
    post:
      summary: Execute economic transaction
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/EconomicTransaction'
      responses:
        '201':
          description: Transaction authorized and executing
        '402':
          description: Transaction exceeds spending limits
        '403': 
          description: Human approval required
          
  /personas/{persona_id}/spending:
    get:
      summary: Get current spending status for persona
      parameters:
        - name: persona_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
        - name: date_range
          in: query
          schema:
            type: string
            enum: [today, week, month]
      responses:
        '200':
          description: Spending data retrieved
          content:
            application/json:
              schema:
                type: object
                properties:
                  daily_spent:
                    type: number
                  daily_remaining:
                    type: number
                  transaction_count:
                    type: integer
                  largest_transaction:
                    type: number
```

## MCP Integration Protocols

### Resource URIs (Data Sources)

```python
# Social Media Data Resources
MCP_RESOURCES = {
    # Twitter data streams
    "twitter://mentions/{persona_handle}/recent": {
        "description": "Recent mentions of the persona",
        "mime_type": "application/json",
        "schema": "social_mention_schema"
    },
    
    # Trend analysis data  
    "trends://global/hourly": {
        "description": "Global trending topics updated hourly",
        "mime_type": "application/json", 
        "schema": "trend_data_schema"
    },
    
    # News feed integration
    "news://technology/latest": {
        "description": "Latest technology news articles",
        "mime_type": "application/json",
        "schema": "news_article_schema"
    },
    
    # Performance analytics
    "analytics://{platform}/{persona_id}/metrics": {
        "description": "Platform-specific performance metrics", 
        "mime_type": "application/json",
        "schema": "analytics_schema"
    }
}
```

### Tool Interfaces (Actions)

```python
# Content Generation Tools
MCP_TOOLS = {
    "generate_social_content": {
        "description": "Generate platform-optimized content",
        "input_schema": {
            "type": "object", 
            "properties": {
                "persona_id": {"type": "string"},
                "platform": {"type": "string"},
                "content_brief": {"type": "string"},
                "trend_context": {"type": "array"}
            }
        },
        "output_schema": {
            "type": "object",
            "properties": {
                "generated_content": {"type": "string"},
                "confidence_score": {"type": "number"},
                "safety_scores": {"type": "object"}
            }
        }
    },
    
    "execute_blockchain_transaction": {
        "description": "Execute cryptocurrency transaction",
        "input_schema": {
            "type": "object",
            "properties": {
                "from_address": {"type": "string"},
                "to_address": {"type": "string"}, 
                "amount_eth": {"type": "number"},
                "transaction_type": {"type": "string"}
            }
        },
        "output_schema": {
            "type": "object",
            "properties": {
                "transaction_hash": {"type": "string"},
                "status": {"type": "string"},
                "gas_used": {"type": "integer"}
            }
        }
    },
    
    "analyze_market_trends": {
        "description": "Analyze social media trends and sentiment",
        "input_schema": {
            "type": "object",
            "properties": {
                "keywords": {"type": "array"},
                "platforms": {"type": "array"},
                "time_range": {"type": "string"}
            }
        },
        "output_schema": {
            "type": "object", 
            "properties": {
                "trend_scores": {"type": "object"},
                "sentiment_analysis": {"type": "object"},
                "recommended_actions": {"type": "array"}
            }
        }
    }
}
```

### Prompt Templates (Reusable Reasoning)

```python
MCP_PROMPTS = {
    "content_generation_prompt": {
        "description": "Generate engaging social media content",
        "template": """
        You are {persona_name} with the following personality: {personality_traits}
        
        Current trending topics: {trend_context}
        Platform: {platform}
        Audience: {target_audience}
        
        Create engaging content that:
        1. Matches the persona's voice and style
        2. Incorporates relevant trending topics
        3. Drives engagement on {platform}
        4. Stays within brand safety guidelines
        
        Content brief: {content_brief}
        """,
        "input_variables": [
            "persona_name", "personality_traits", "trend_context", 
            "platform", "target_audience", "content_brief"
        ]
    },
    
    "confidence_assessment_prompt": {
        "description": "Assess content quality and confidence",
        "template": """
        Evaluate the following content for publication readiness:
        
        Content: {generated_content}
        Persona Guidelines: {persona_constraints}
        Platform: {platform}
        
        Assess:
        1. Brand alignment (0-100)
        2. Engagement potential (0-100)  
        3. Safety compliance (0-100)
        4. Audience appropriateness (0-100)
        
        Provide overall confidence score (0-1) and explanation.
        """,
        "input_variables": [
            "generated_content", "persona_constraints", "platform"
        ]
    }
}
```

## Performance & Scalability Requirements

### System Performance Targets

| Metric | Target | Measurement |
|--------|---------|-------------|
| Task Processing Latency | <10 seconds | End-to-end content creation |
| System Throughput | 10,000 tasks/hour | Per orchestrator instance |
| Agent Fleet Size | 1000+ concurrent | Horizontal scaling capability |
| Database Query Time | <100ms | 95th percentile |
| MCP Tool Response | <2 seconds | External API integration |
| Memory Usage/Agent | <500MB | Resource utilization |
| CPU Usage/Agent | <0.5 cores | Computational efficiency |

### Scaling Architecture

```python
# Horizontal Scaling Configuration
SCALING_CONFIG = {
    "orchestrator": {
        "min_instances": 3,
        "max_instances": 20, 
        "scale_trigger": "queue_depth > 1000"
    },
    "planner_agents": {
        "min_instances": 5,
        "max_instances": 50,
        "scale_trigger": "avg_response_time > 5s"
    },
    "worker_agents": {
        "min_instances": 20,
        "max_instances": 500,
        "scale_trigger": "cpu_usage > 70%"
    },
    "judge_agents": {
        "min_instances": 10, 
        "max_instances": 100,
        "scale_trigger": "review_queue_size > 100"
    }
}
```

---

**Implementation Notes**:
1. All schemas must be validated at runtime using Pydantic models
2. Database migrations managed through Alembic for schema evolution
3. MCP integrations use async/await for non-blocking operations  
4. All financial transactions require multi-signature authorization
5. Performance monitoring through Prometheus metrics collection

**Next Steps**: OpenClaw integration protocol and test suite creation