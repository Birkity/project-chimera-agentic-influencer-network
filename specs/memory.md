# Project Chimera - Agent Memory System Specification

**Document**: `specs/memory.md`  
**Version**: 1.0.0  
**Last Updated**: February 6, 2026  
**Dependencies**: [_meta.md](specs/_meta.md), [technical.md](specs/technical.md), [persona.md](specs/persona.md)

## Overview

Project Chimera implements a **hierarchical memory architecture** combining short-term episodic memory with long-term semantic memory to enable context-aware agent behavior over extended timeframes. This specification defines memory storage, retrieval, and evolution patterns using Retrieval-Augmented Generation (RAG) with Redis and Weaviate.

---

## Memory Architecture Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                    Memory Retrieval Pipeline                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Incoming Query/Context                                         │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────────────────────────────────────┐           │
│  │  Short-Term Memory (Episodic) - Redis           │           │
│  │  • Last 1 hour of interactions                  │           │
│  │  • Current conversation context                 │           │
│  │  • Active tasks and status                      │           │
│  │  • Real-time emotional state                    │           │
│  └─────────────────────────────────────────────────┘           │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────────────────────────────────────┐           │
│  │  Long-Term Memory (Semantic) - Weaviate         │           │
│  │  • Historical interactions (months/years)       │           │
│  │  • Learned preferences and patterns             │           │
│  │  • Successful content strategies                │           │
│  │  • Relationship context with users              │           │
│  └─────────────────────────────────────────────────┘           │
│           │                                                      │
│           ▼                                                      │
│  ┌─────────────────────────────────────────────────┐           │
│  │  Context Assembly for LLM                       │           │
│  │  SOUL.md + Short-Term + Long-Term Memories      │           │
│  └─────────────────────────────────────────────────┘           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Short-Term Memory (Episodic)

### Purpose & Characteristics

**Storage**: Redis (in-memory key-value store)  
**Retention**: 1 hour sliding window  
**Access Pattern**: Synchronous, ultra-low latency (<1ms)  
**Use Case**: Immediate conversation context, task state tracking

### Redis Schema Design

#### Conversation History

```redis
# Key pattern: chimera:agent:{agent_id}:conversation:{session_id}
# Data structure: List (FIFO with TTL)

LPUSH chimera:agent:001:conversation:session-abc [
  {
    "timestamp": "2026-02-06T10:30:15Z",
    "role": "user",
    "content": "What's trending in Ethiopian tech?",
    "platform": "twitter",
    "user_handle": "@techfan123"
  },
  {
    "timestamp": "2026-02-06T10:30:18Z",
    "role": "assistant",
    "content": "Great question! I'm seeing huge momentum around...",
    "confidence_score": 0.92,
    "engagement_prediction": 0.78
  }
]

# Auto-expire after 1 hour
EXPIRE chimera:agent:001:conversation:session-abc 3600
```

#### Active Task State

```redis
# Key pattern: chimera:agent:{agent_id}:tasks:active
# Data structure: Hash

HSET chimera:agent:001:tasks:active task-uuid-1 {
  "task_id": "uuid-v4-string",
  "task_type": "content_creation",
  "status": "in_progress",
  "created_at": "2026-02-06T10:25:00Z",
  "estimated_completion": "2026-02-06T10:35:00Z",
  "worker_assigned": "worker-pool-03",
  "confidence_so_far": 0.85
}
```

#### Recent Emotional State

```redis
# Key pattern: chimera:agent:{agent_id}:emotional_state
# Data structure: JSON with TTL

SET chimera:agent:001:emotional_state {
  "primary_emotion": "engaged",
  "confidence_level": 0.88,
  "conversation_sentiment": "positive",
  "stress_indicators": {
    "queue_depth": 5,
    "error_rate": 0.02,
    "response_latency_avg": 2.3
  },
  "last_updated": "2026-02-06T10:30:00Z"
}
EXPIRE chimera:agent:001:emotional_state 3600
```

#### Daily Spend Tracker (Budget Monitoring)

```redis
# Key pattern: chimera:agent:{agent_id}:budget:daily:{date}
# Data structure: Hash

HSET chimera:agent:001:budget:daily:2026-02-06 
  total_spent 32.50
  transaction_count 8
  last_transaction_time "2026-02-06T09:15:00Z"
  
EXPIRE chimera:agent:001:budget:daily:2026-02-06 86400
```

### Short-Term Memory Retrieval API

```python
from typing import List, Dict, Optional
import redis.asyncio as redis
import json
from datetime import datetime, timedelta

class ShortTermMemory:
    def __init__(self, redis_client: redis.Redis):
        self.redis = redis_client
    
    async def get_recent_context(
        self, 
        agent_id: str, 
        session_id: str,
        limit: int = 20
    ) -> List[Dict]:
        """
        Retrieve recent conversation history
        """
        key = f"chimera:agent:{agent_id}:conversation:{session_id}"
        messages = await self.redis.lrange(key, 0, limit - 1)
        return [json.loads(msg) for msg in messages]
    
    async def add_interaction(
        self,
        agent_id: str,
        session_id: str,
        role: str,
        content: str,
        metadata: Dict
    ):
        """
        Add new interaction to short-term memory
        """
        key = f"chimera:agent:{agent_id}:conversation:{session_id}"
        interaction = {
            "timestamp": datetime.utcnow().isoformat(),
            "role": role,
            "content": content,
            **metadata
        }
        
        await self.redis.lpush(key, json.dumps(interaction))
        await self.redis.expire(key, 3600)  # 1 hour TTL
    
    async def get_active_tasks(self, agent_id: str) -> List[Dict]:
        """
        Retrieve currently active tasks
        """
        key = f"chimera:agent:{agent_id}:tasks:active"
        tasks = await self.redis.hgetall(key)
        return [json.loads(task) for task in tasks.values()]
    
    async def get_emotional_state(self, agent_id: str) -> Optional[Dict]:
        """
        Retrieve current emotional/operational state
        """
        key = f"chimera:agent:{agent_id}:emotional_state"
        state = await self.redis.get(key)
        return json.loads(state) if state else None
```

---

## Long-Term Memory (Semantic)

### Purpose & Characteristics

**Storage**: Weaviate (vector database)  
**Retention**: Indefinite (with archival policies)  
**Access Pattern**: Asynchronous, semantic similarity search  
**Use Case**: Historical context, learned patterns, relationship building

### Weaviate Schema Design

#### AgentMemory Collection

```python
{
  "class": "AgentMemory",
  "description": "Long-term semantic memory for Chimera agents",
  "vectorizer": "text2vec-openai",
  "moduleConfig": {
    "text2vec-openai": {
      "model": "text-embedding-3-large",
      "dimensions": 1536,
      "type": "text"
    }
  },
  "properties": [
    {
      "name": "agent_id",
      "dataType": ["string"],
      "description": "Chimera agent identifier"
    },
    {
      "name": "memory_type",
      "dataType": ["string"],
      "description": "Type of memory: interaction, learning, achievement, relationship"
    },
    {
      "name": "content",
      "dataType": ["text"],
      "description": "The actual memory content (vectorized for semantic search)"
    },
    {
      "name": "context",
      "dataType": ["text"],
      "description": "Additional context about the memory formation"
    },
    {
      "name": "timestamp",
      "dataType": ["date"],
      "description": "When the memory was created"
    },
    {
      "name": "importance_score",
      "dataType": ["number"],
      "description": "Memory significance (0.0-1.0)"
    },
    {
      "name": "emotional_valence",
      "dataType": ["string"],
      "description": "Emotional context: positive, negative, neutral"
    },
    {
      "name": "entities",
      "dataType": ["string[]"],
      "description": "Extracted entities (people, places, topics)"
    },
    {
      "name": "platform_source",
      "dataType": ["string"],
      "description": "Where this memory originated"
    },
    {
      "name": "retrieval_count",
      "dataType": ["int"],
      "description": "How many times this memory has been recalled"
    },
    {
      "name": "success_metrics",
      "dataType": ["object"],
      "description": "Associated performance data (engagement, revenue, etc.)"
    }
  ],
  "vectorIndexType": "hnsw",
  "vectorIndexConfig": {
    "ef": 256,
    "efConstruction": 128,
    "maxConnections": 64
  }
}
```

#### Memory Type Categories

**1. Interaction Memory**

```json
{
  "memory_type": "interaction",
  "content": "Had a great conversation with @techfan123 about emerging Ethiopian AI startups. They were particularly interested in fintech applications. Provided recommendations for local accelerators.",
  "context": "Twitter DM conversation, user showed high technical literacy",
  "importance_score": 0.75,
  "emotional_valence": "positive",
  "entities": ["@techfan123", "Ethiopian AI", "fintech", "accelerators"],
  "platform_source": "twitter",
  "success_metrics": {
    "user_satisfaction": 0.92,
    "conversation_length": 8,
    "follow_up_engagement": true
  }
}
```

**2. Learning Memory**

```json
{
  "memory_type": "learning",
  "content": "Content posted at 7-9 PM EAT consistently gets 40% higher engagement than morning posts. Audience is most active during evening hours.",
  "context": "Analysis of 30 days of posting data across platforms",
  "importance_score": 0.90,
  "emotional_valence": "neutral",
  "entities": ["posting_schedule", "engagement_optimization", "EAT_timezone"],
  "success_metrics": {
    "data_points": 120,
    "confidence_level": 0.87,
    "improvement_potential": 0.40
  }
}
```

**3. Achievement Memory**

```json
{
  "memory_type": "achievement",
  "content": "Created viral video about Ethiopian coffee ceremony that reached 500K views. Key success factors: authentic cultural storytelling, high production quality, trending audio.",
  "context": "TikTok video posted during International Coffee Day",
  "importance_score": 0.95,
  "emotional_valence": "positive",
  "entities": ["Ethiopian_coffee", "viral_content", "cultural_storytelling"],
  "success_metrics": {
    "views": 500000,
    "engagement_rate": 0.089,
    "revenue_generated": 245.50,
    "brand_partnerships": 3
  }
}
```

**4. Relationship Memory**

```json
{
  "memory_type": "relationship",
  "content": "@brandpartner_xyz prefers formal communication, responds best to data-driven proposals, decision-maker available Tuesdays/Thursdays. Partnership focus: tech education content.",
  "context": "Built over 6 months of collaboration",
  "importance_score": 0.88,
  "emotional_valence": "positive",
  "entities": ["@brandpartner_xyz", "B2B_relationship", "tech_education"],
  "success_metrics": {
    "contracts_signed": 4,
    "total_revenue": 2800.00,
    "satisfaction_score": 0.91
  }
}
```

### Long-Term Memory Retrieval API

```python
import weaviate
from weaviate.classes.query import MetadataQuery
from typing import List, Dict, Optional

class LongTermMemory:
    def __init__(self, weaviate_client: weaviate.WeaviateClient):
        self.client = weaviate_client
    
    async def semantic_search(
        self,
        agent_id: str,
        query: str,
        limit: int = 5,
        memory_types: Optional[List[str]] = None,
        min_importance: float = 0.0
    ) -> List[Dict]:
        """
        Semantic search for relevant memories
        """
        collection = self.client.collections.get("AgentMemory")
        
        # Build filters
        filters = weaviate.classes.query.Filter.by_property("agent_id").equal(agent_id)
        
        if memory_types:
            type_filter = weaviate.classes.query.Filter.by_property("memory_type").contains_any(memory_types)
            filters = filters & type_filter
        
        if min_importance > 0.0:
            importance_filter = weaviate.classes.query.Filter.by_property("importance_score").greater_or_equal(min_importance)
            filters = filters & importance_filter
        
        # Execute semantic search
        response = collection.query.near_text(
            query=query,
            limit=limit,
            filters=filters,
            return_metadata=MetadataQuery(distance=True, certainty=True)
        )
        
        return [
            {
                "content": obj.properties["content"],
                "memory_type": obj.properties["memory_type"],
                "timestamp": obj.properties["timestamp"],
                "importance": obj.properties["importance_score"],
                "relevance": obj.metadata.certainty,
                "entities": obj.properties["entities"],
                "success_metrics": obj.properties.get("success_metrics", {})
            }
            for obj in response.objects
        ]
    
    async def add_memory(
        self,
        agent_id: str,
        memory_type: str,
        content: str,
        context: str,
        importance_score: float,
        emotional_valence: str,
        entities: List[str],
        platform_source: str,
        success_metrics: Optional[Dict] = None
    ) -> str:
        """
        Store new long-term memory
        """
        collection = self.client.collections.get("AgentMemory")
        
        memory_object = {
            "agent_id": agent_id,
            "memory_type": memory_type,
            "content": content,
            "context": context,
            "timestamp": datetime.utcnow().isoformat(),
            "importance_score": importance_score,
            "emotional_valence": emotional_valence,
            "entities": entities,
            "platform_source": platform_source,
            "retrieval_count": 0,
            "success_metrics": success_metrics or {}
        }
        
        result = collection.data.insert(memory_object)
        return str(result)
    
    async def increment_retrieval_count(self, memory_id: str):
        """
        Track memory usage for importance scoring
        """
        collection = self.client.collections.get("AgentMemory")
        
        memory = collection.query.fetch_object_by_id(memory_id)
        current_count = memory.properties["retrieval_count"]
        
        collection.data.update(
            uuid=memory_id,
            properties={"retrieval_count": current_count + 1}
        )
```

---

## Context Assembly Pipeline

### Integrated Memory Retrieval

```python
from typing import Dict, List
from chimera.persona import AgentPersona
from chimera.memory import ShortTermMemory, LongTermMemory

class ContextAssembler:
    """
    Combines SOUL.md persona, short-term episodic memory,
    and long-term semantic memory into LLM context
    """
    
    def __init__(
        self,
        persona: AgentPersona,
        short_term: ShortTermMemory,
        long_term: LongTermMemory
    ):
        self.persona = persona
        self.short_term = short_term
        self.long_term = long_term
    
    async def assemble_context(
        self,
        agent_id: str,
        session_id: str,
        current_query: str,
        max_context_tokens: int = 8000
    ) -> str:
        """
        Build complete context for LLM reasoning
        """
        context_parts = []
        
        # Part 1: Core Persona (from SOUL.md)
        context_parts.append(self._format_persona_context())
        
        # Part 2: Short-Term Memory (last hour)
        recent_messages = await self.short_term.get_recent_context(
            agent_id, session_id, limit=20
        )
        context_parts.append(self._format_short_term_context(recent_messages))
        
        # Part 3: Long-Term Memory (semantic search)
        relevant_memories = await self.long_term.semantic_search(
            agent_id=agent_id,
            query=current_query,
            limit=5,
            min_importance=0.70
        )
        context_parts.append(self._format_long_term_context(relevant_memories))
        
        # Part 4: Current Operational State
        emotional_state = await self.short_term.get_emotional_state(agent_id)
        active_tasks = await self.short_term.get_active_tasks(agent_id)
        context_parts.append(self._format_operational_context(emotional_state, active_tasks))
        
        # Assemble with token management
        return self._truncate_to_token_limit(
            "\n\n".join(context_parts),
            max_context_tokens
        )
    
    def _format_persona_context(self) -> str:
        return f"""
# WHO YOU ARE

**Name**: {self.persona.persona_name}
**Backstory**: {self.persona.backstory}

**Communication Style**: {self.persona.communication_tone}
**Voice Traits**: {', '.join(self.persona.voice_traits)}

**Core Values**:
{chr(10).join(f'- {value}' for value in self.persona.core_values)}

**Behavioral Rules**:
MUST: {chr(10).join(f'- {rule}' for rule in self.persona.must_do)}
MUST NOT: {chr(10).join(f'- {rule}' for rule in self.persona.must_not_do)}
"""
    
    def _format_short_term_context(self, messages: List[Dict]) -> str:
        if not messages:
            return "# RECENT CONVERSATION\n\nNo recent interaction history."
        
        formatted_messages = []
        for msg in messages:
            role = msg['role'].upper()
            content = msg['content']
            timestamp = msg['timestamp']
            formatted_messages.append(f"[{timestamp}] {role}: {content}")
        
        return f"""
# RECENT CONVERSATION (Last Hour)

{chr(10).join(formatted_messages)}
"""
    
    def _format_long_term_context(self, memories: List[Dict]) -> str:
        if not memories:
            return "# RELEVANT MEMORIES\n\nNo relevant past memories found."
        
        formatted_memories = []
        for mem in memories:
            formatted_memories.append(f"""
**Memory Type**: {mem['memory_type']}
**Content**: {mem['content']}
**Relevance**: {mem['relevance']:.2f}
**When**: {mem['timestamp']}
""")
        
        return f"""
# RELEVANT MEMORIES FROM YOUR HISTORY

{chr(10).join(formatted_memories)}
"""
    
    def _format_operational_context(self, emotional_state: Dict, active_tasks: List[Dict]) -> str:
        state_summary = "Unknown"
        if emotional_state:
            state_summary = f"{emotional_state['primary_emotion']} (confidence: {emotional_state['confidence_level']:.2f})"
        
        task_summary = f"{len(active_tasks)} active tasks"
        
        return f"""
# CURRENT OPERATIONAL STATE

**Emotional State**: {state_summary}
**Active Workload**: {task_summary}
**System Status**: Operational
"""
```

---

## Memory Evolution & Learning

### Dynamic Memory Creation

```python
class MemoryEvolutionEngine:
    """
    Automatically create long-term memories from successful interactions
    """
    
    async def analyze_interaction_for_memory_creation(
        self,
        agent_id: str,
        interaction_data: Dict,
        success_metrics: Dict
    ):
        """
        Judge Agent triggers this after successful high-engagement interactions
        """
        # Calculate importance score
        importance = self._calculate_importance(interaction_data, success_metrics)
        
        if importance >= 0.70:  # Threshold for memory worthiness
            # Extract key learnings
            memory_content = await self._summarize_interaction(interaction_data)
            entities = self._extract_entities(interaction_data)
            
            # Store as long-term memory
            await self.long_term.add_memory(
                agent_id=agent_id,
                memory_type="learning",
                content=memory_content,
                context=interaction_data.get('context', ''),
                importance_score=importance,
                emotional_valence=self._assess_valence(success_metrics),
                entities=entities,
                platform_source=interaction_data.get('platform', 'unknown'),
                success_metrics=success_metrics
            )
    
    def _calculate_importance(self, interaction: Dict, metrics: Dict) -> float:
        """
        Multi-factor importance scoring
        """
        factors = []
        
        # Engagement performance
        if 'engagement_rate' in metrics:
            factors.append(min(metrics['engagement_rate'] / 0.10, 1.0))
        
        # Revenue impact
        if 'revenue_generated' in metrics and metrics['revenue_generated'] > 0:
            factors.append(0.90)
        
        # Unique learning opportunity
        if interaction.get('novel_pattern', False):
            factors.append(0.85)
        
        # Relationship building
        if interaction.get('relationship_deepening', False):
            factors.append(0.80)
        
        return sum(factors) / len(factors) if factors else 0.50
```

### Memory Archival Policy

```python
class MemoryArchivalPolicy:
    """
    Manage memory lifecycle to prevent database bloat
    """
    
    async def archive_old_low_importance_memories(self, agent_id: str):
        """
        Run daily: Archive memories older than 6 months with low retrieval count
        """
        cutoff_date = datetime.utcnow() - timedelta(days=180)
        
        # Find candidates for archival
        collection = self.client.collections.get("AgentMemory")
        
        response = collection.query.fetch_objects(
            filters=(
                weaviate.classes.query.Filter.by_property("agent_id").equal(agent_id)
                & weaviate.classes.query.Filter.by_property("timestamp").less_than(cutoff_date.isoformat())
                & weaviate.classes.query.Filter.by_property("retrieval_count").less_than(3)
                & weaviate.classes.query.Filter.by_property("importance_score").less_than(0.60)
            )
        )
        
        # Archive to cold storage (S3, etc.)
        for obj in response.objects:
            await self._export_to_archive(obj)
            collection.data.delete_by_id(obj.uuid)
```

---

## Integration with MCP Resources

### Memory as MCP Resource

```python
from mcp.server import Server
from mcp.types import Resource, TextContent

# Expose memory as MCP resource
@server.resource("chimera://memory/{agent_id}/recent")
async def memory_resource_recent(agent_id: str) -> Resource:
    """
    Recent memory accessible via MCP protocol
    """
    memories = await short_term.get_recent_context(agent_id, session_id="current")
    
    return Resource(
        uri=f"chimera://memory/{agent_id}/recent",
        name=f"Recent memories for {agent_id}",
        mimeType="application/json",
        text=json.dumps(memories, indent=2)
    )
```

---

## Performance Optimization

### Caching Strategy

- Redis short-term: <1ms retrieval
- Weaviate semantic search: <100ms typical
- Context assembly: <200ms total pipeline

### Scaling Considerations

- Shard Weaviate by agent_id for >10K agents
- Redis cluster mode for high-traffic scenarios
- Memory compression for archival storage

---

**Memory System Status**: SPECIFICATION APPROVED  
**Implementation Priority**: HIGH (Core cognitive capability)  
**Performance Target**: <200ms end-to-end context assembly
