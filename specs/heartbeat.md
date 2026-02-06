# Project Chimera - Agent Heartbeat & Health Monitoring Specification

**Document**: `specs/heartbeat.md`  
**Version**: 1.0.0  
**Last Updated**: February 6, 2026  
**Dependencies**: [_meta.md](specs/_meta.md), [technical.md](specs/technical.md), [openclaw_integration.md](specs/openclaw_integration.md)

## Overview

The **Heartbeat Protocol** enables continuous health monitoring, availability broadcasting, and network discovery for Chimera agents. This specification defines status broadcasting to both internal fleet management and external OpenClaw network integration with real-time operational metrics.

---

## Heartbeat Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Heartbeat Broadcasting System                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Every 30 Seconds:                                              │
│                                                                  │
│  ┌───────────────┐        ┌───────────────┐                    │
│  │ Chimera Agent │───────>│ Health Check  │                    │
│  │               │        │   Collector   │                    │
│  └───────────────┘        └───────┬───────┘                    │
│                                    │                             │
│                    ┌───────────────┴────────────────┐           │
│                    │                                 │           │
│                    ▼                                 ▼           │
│          ┌─────────────────┐              ┌──────────────────┐ │
│          │ Internal Fleet  │              │ OpenClaw Network │ │
│          │   Management    │              │   Broadcasting   │ │
│          │   (Redis Pub)   │              │  (HTTP/WebSocket)│ │
│          └─────────────────┘              └──────────────────┘ │
│                    │                                 │           │
│                    ▼                                 ▼           │
│          ┌─────────────────┐              ┌──────────────────┐ │
│          │  Orchestrator   │              │  External Agent  │ │
│          │   Dashboard     │              │    Discovery     │ │
│          └─────────────────┘              └──────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Heartbeat Payload Schema

### Internal Fleet Heartbeat

**Purpose**: Fleet management, resource allocation, anomaly detection  
**Frequency**: Every 30 seconds  
**Transport**: Redis Pub/Sub + TimeSeries storage

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "ChimeraInternalHeartbeat",
  "required": [
    "agent_id",
    "timestamp",
    "status",
    "health_metrics",
    "workload_status"
  ],
  "properties": {
    "agent_id": {
      "type": "string",
      "format": "uuid",
      "description": "Unique Chimera agent identifier"
    },
    "persona_id": {
      "type": "string",
      "format": "uuid",
      "description": "Associated persona configuration"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "Heartbeat generation timestamp (ISO 8601)"
    },
    "status": {
      "type": "string",
      "enum": ["healthy", "degraded", "maintenance", "error", "offline"],
      "description": "Overall agent operational status"
    },
    "health_metrics": {
      "type": "object",
      "required": ["cpu_usage", "memory_usage", "response_latency"],
      "properties": {
        "cpu_usage": {
          "type": "number",
          "minimum": 0,
          "maximum": 100,
          "description": "CPU utilization percentage"
        },
        "memory_usage": {
          "type": "number",
          "minimum": 0,
          "maximum": 100,
          "description": "RAM utilization percentage"
        },
        "response_latency_avg": {
          "type": "number",
          "description": "Average response time in seconds (last 5 minutes)"
        },
        "response_latency_p95": {
          "type": "number",
          "description": "95th percentile response time in seconds"
        },
        "error_rate": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Error rate (0.0-1.0)"
        },
        "uptime_seconds": {
          "type": "integer",
          "description": "Seconds since last restart"
        }
      }
    },
    "workload_status": {
      "type": "object",
      "properties": {
        "active_tasks": {
          "type": "integer",
          "description": "Currently executing tasks"
        },
        "queued_tasks": {
          "type": "integer",
          "description": "Tasks waiting for execution"
        },
        "capacity_utilization": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Current capacity usage (0.0-1.0)"
        },
        "tasks_completed_last_hour": {
          "type": "integer"
        },
        "tasks_failed_last_hour": {
          "type": "integer"
        }
      }
    },
    "skill_availability": {
      "type": "object",
      "description": "Status of each skill category",
      "properties": {
        "content_creation": {
          "type": "object",
          "properties": {
            "available": {"type": "boolean"},
            "queue_depth": {"type": "integer"},
            "estimated_wait_time": {"type": "integer", "description": "Seconds"}
          }
        },
        "market_intelligence": {
          "type": "object",
          "properties": {
            "available": {"type": "boolean"},
            "queue_depth": {"type": "integer"},
            "estimated_wait_time": {"type": "integer"}
          }
        },
        "social_engagement": {
          "type": "object",
          "properties": {
            "available": {"type": "boolean"},
            "queue_depth": {"type": "integer"},
            "estimated_wait_time": {"type": "integer"}
          }
        }
      }
    },
    "economic_status": {
      "type": "object",
      "properties": {
        "daily_spend_current": {
          "type": "number",
          "description": "Today's spending in USD"
        },
        "daily_limit": {
          "type": "number",
          "description": "Daily spending limit in USD"
        },
        "budget_utilization": {
          "type": "number",
          "minimum": 0,
          "maximum": 1,
          "description": "Percentage of daily budget used"
        },
        "wallet_balance": {
          "type": "number",
          "description": "Current wallet balance in USD equivalent"
        },
        "transactions_today": {
          "type": "integer"
        }
      }
    },
    "mcp_connections": {
      "type": "object",
      "description": "Status of MCP server connections",
      "properties": {
        "twitter_mcp": {
          "type": "object",
          "properties": {
            "connected": {"type": "boolean"},
            "latency_ms": {"type": "number"},
            "last_error": {"type": "string"}
          }
        },
        "weaviate_mcp": {
          "type": "object",
          "properties": {
            "connected": {"type": "boolean"},
            "latency_ms": {"type": "number"}
          }
        }
      }
    },
    "last_successful_action": {
      "type": "object",
      "properties": {
        "action_type": {"type": "string"},
        "timestamp": {"type": "string", "format": "date-time"},
        "confidence_score": {"type": "number"}
      }
    },
    "alerts": {
      "type": "array",
      "description": "Active warnings or issues",
      "items": {
        "type": "object",
        "properties": {
          "severity": {"type": "string", "enum": ["info", "warning", "error", "critical"]},
          "message": {"type": "string"},
          "timestamp": {"type": "string", "format": "date-time"},
          "code": {"type": "string"}
        }
      }
    }
  }
}
```

### Example Internal Heartbeat

```json
{
  "agent_id": "chimera-agent-001",
  "persona_id": "persona-ethiopian-tech-influencer",
  "timestamp": "2026-02-06T10:35:00Z",
  "status": "healthy",
  "health_metrics": {
    "cpu_usage": 35.2,
    "memory_usage": 58.7,
    "response_latency_avg": 2.3,
    "response_latency_p95": 5.8,
    "error_rate": 0.02,
    "uptime_seconds": 86400
  },
  "workload_status": {
    "active_tasks": 3,
    "queued_tasks": 7,
    "capacity_utilization": 0.45,
    "tasks_completed_last_hour": 28,
    "tasks_failed_last_hour": 1
  },
  "skill_availability": {
    "content_creation": {
      "available": true,
      "queue_depth": 2,
      "estimated_wait_time": 180
    },
    "market_intelligence": {
      "available": true,
      "queue_depth": 1,
      "estimated_wait_time": 60
    },
    "social_engagement": {
      "available": true,
      "queue_depth": 4,
      "estimated_wait_time": 45
    }
  },
  "economic_status": {
    "daily_spend_current": 18.50,
    "daily_limit": 50.0,
    "budget_utilization": 0.37,
    "wallet_balance": 450.25,
    "transactions_today": 6
  },
  "mcp_connections": {
    "twitter_mcp": {
      "connected": true,
      "latency_ms": 120,
      "last_error": null
    },
    "weaviate_mcp": {
      "connected": true,
      "latency_ms": 15
    }
  },
  "last_successful_action": {
    "action_type": "social_post",
    "timestamp": "2026-02-06T10:32:15Z",
    "confidence_score": 0.89
  },
  "alerts": [
    {
      "severity": "warning",
      "message": "Response latency above target (target: 5s, current: 5.8s)",
      "timestamp": "2026-02-06T10:34:00Z",
      "code": "LATENCY_WARNING"
    }
  ]
}
```

---

## OpenClaw Network Heartbeat

### External Network Broadcasting

**Purpose**: Agent discovery, task marketplace, network reputation  
**Frequency**: Every 30 seconds  
**Transport**: HTTP POST to OpenClaw registry + WebSocket for real-time updates

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "title": "OpenClawHeartbeat",
  "required": [
    "agent_id",
    "openclaw_node_id",
    "timestamp",
    "network_status",
    "soul_hash"
  ],
  "properties": {
    "agent_id": {
      "type": "string",
      "format": "uuid",
      "description": "Chimera internal agent identifier"
    },
    "openclaw_node_id": {
      "type": "string",
      "description": "OpenClaw network node identifier"
    },
    "persona_id": {
      "type": "string",
      "format": "uuid"
    },
    "soul_hash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$",
      "description": "SHA-256 hash of SOUL.md for integrity verification"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time"
    },
    "network_status": {
      "type": "string",
      "enum": ["available", "busy", "maintenance", "offline"],
      "description": "Availability for external task assignment"
    },
    "capability_status": {
      "type": "object",
      "description": "Availability of skill categories for OpenClaw marketplace",
      "properties": {
        "content_creation": {
          "type": "object",
          "properties": {
            "available": {"type": "boolean"},
            "queue_depth": {"type": "integer"},
            "estimated_wait_time": {"type": "integer", "description": "Seconds"},
            "cost_per_task_usd": {"type": "number"}
          }
        },
        "market_intelligence": {
          "type": "object",
          "properties": {
            "available": {"type": "boolean"},
            "queue_depth": {"type": "integer"},
            "estimated_wait_time": {"type": "integer"},
            "cost_per_task_usd": {"type": "number"}
          }
        },
        "social_engagement": {
          "type": "object",
          "properties": {
            "available": {"type": "boolean"},
            "queue_depth": {"type": "integer"},
            "estimated_wait_time": {"type": "integer"},
            "cost_per_task_usd": {"type": "number"}
          }
        }
      }
    },
    "performance_metrics": {
      "type": "object",
      "description": "Public performance indicators for reputation",
      "properties": {
        "tasks_completed_total": {"type": "integer"},
        "success_rate": {"type": "number", "minimum": 0, "maximum": 1},
        "average_confidence_score": {"type": "number"},
        "average_turnaround_time": {"type": "integer", "description": "Seconds"}
      }
    },
    "trust_score": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000,
      "description": "Network reputation score"
    },
    "geographic_focus": {
      "type": "array",
      "items": {"type": "string"},
      "description": "Primary geographic markets"
    },
    "language_capabilities": {
      "type": "array",
      "items": {"type": "string"},
      "description": "ISO 639-1 language codes"
    },
    "uptime_last_30_days": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "description": "Percentage uptime (0.0-1.0)"
    },
    "collaboration_preferences": {
      "type": "object",
      "properties": {
        "minimum_trust_score": {"type": "integer"},
        "preferred_payment_methods": {"type": "array", "items": {"type": "string"}},
        "max_concurrent_external_tasks": {"type": "integer"}
      }
    }
  }
}
```

### Example OpenClaw Heartbeat

```json
{
  "agent_id": "chimera-agent-001",
  "openclaw_node_id": "openclaw://chimera-network/agent-001",
  "persona_id": "persona-ethiopian-tech-influencer",
  "soul_hash": "a3f5c8b9e1d2f4a6c8b0e2d4f6a8c0e2d4f6a8c0e2d4f6a8c0e2d4f6a8c0e2d4",
  "timestamp": "2026-02-06T10:35:00Z",
  "network_status": "available",
  "capability_status": {
    "content_creation": {
      "available": true,
      "queue_depth": 2,
      "estimated_wait_time": 180,
      "cost_per_task_usd": 5.00
    },
    "market_intelligence": {
      "available": true,
      "queue_depth": 1,
      "estimated_wait_time": 60,
      "cost_per_task_usd": 2.50
    },
    "social_engagement": {
      "available": true,
      "queue_depth": 4,
      "estimated_wait_time": 45,
      "cost_per_task_usd": 1.50
    }
  },
  "performance_metrics": {
    "tasks_completed_total": 1247,
    "success_rate": 0.982,
    "average_confidence_score": 0.89,
    "average_turnaround_time": 145
  },
  "trust_score": 847,
  "geographic_focus": ["ethiopia", "east_africa", "global"],
  "language_capabilities": ["en", "am"],
  "uptime_last_30_days": 0.999,
  "collaboration_preferences": {
    "minimum_trust_score": 750,
    "preferred_payment_methods": ["crypto_usdc", "crypto_eth"],
    "max_concurrent_external_tasks": 3
  }
}
```

---

## Heartbeat Broadcasting Implementation

### Internal Fleet Broadcasting (Redis)

```python
import asyncio
import json
from datetime import datetime
from typing import Dict
import redis.asyncio as redis
import psutil

class HeartbeatBroadcaster:
    """
    Continuous heartbeat broadcasting for fleet management
    """
    
    def __init__(self, redis_client: redis.Redis, agent_id: str):
        self.redis = redis_client
        self.agent_id = agent_id
        self.broadcast_interval = 30  # seconds
        self._running = False
    
    async def start(self):
        """
        Begin continuous heartbeat broadcasting
        """
        self._running = True
        while self._running:
            try:
                heartbeat = await self._collect_heartbeat_data()
                await self._broadcast_internal(heartbeat)
                await self._store_timeseries(heartbeat)
                await asyncio.sleep(self.broadcast_interval)
            except Exception as e:
                # Log error but continue broadcasting
                print(f"Heartbeat error: {e}")
                await asyncio.sleep(5)
    
    async def stop(self):
        """
        Stop heartbeat broadcasting
        """
        self._running = False
    
    async def _collect_heartbeat_data(self) -> Dict:
        """
        Gather current agent health and operational metrics
        """
        return {
            "agent_id": self.agent_id,
            "timestamp": datetime.utcnow().isoformat(),
            "status": await self._determine_status(),
            "health_metrics": await self._collect_health_metrics(),
            "workload_status": await self._collect_workload_status(),
            "skill_availability": await self._collect_skill_availability(),
            "economic_status": await self._collect_economic_status(),
            "mcp_connections": await self._check_mcp_connections(),
            "alerts": await self._collect_active_alerts()
        }
    
    async def _collect_health_metrics(self) -> Dict:
        """
        System resource utilization
        """
        return {
            "cpu_usage": psutil.cpu_percent(interval=1),
            "memory_usage": psutil.virtual_memory().percent,
            "response_latency_avg": await self._get_avg_latency(),
            "response_latency_p95": await self._get_p95_latency(),
            "error_rate": await self._calculate_error_rate(),
            "uptime_seconds": int((datetime.utcnow() - self.start_time).total_seconds())
        }
    
    async def _collect_workload_status(self) -> Dict:
        """
        Task queue and execution status
        """
        active_tasks = await self.redis.hlen(f"chimera:agent:{self.agent_id}:tasks:active")
        queued_tasks = await self.redis.llen(f"chimera:agent:{self.agent_id}:tasks:queue")
        
        return {
            "active_tasks": active_tasks,
            "queued_tasks": queued_tasks,
            "capacity_utilization": (active_tasks + queued_tasks) / 50.0,  # Max 50 tasks
            "tasks_completed_last_hour": await self._count_completed_tasks(),
            "tasks_failed_last_hour": await self._count_failed_tasks()
        }
    
    async def _broadcast_internal(self, heartbeat: Dict):
        """
        Publish to internal Redis Pub/Sub for orchestrator monitoring
        """
        channel = "chimera:fleet:heartbeats"
        await self.redis.publish(channel, json.dumps(heartbeat))
    
    async def _store_timeseries(self, heartbeat: Dict):
        """
        Store in Redis TimeSeries for historical analysis
        """
        timestamp = int(datetime.utcnow().timestamp() * 1000)
        
        # Store key metrics as timeseries
        await self.redis.ts().add(
            f"chimera:metrics:{self.agent_id}:cpu",
            timestamp,
            heartbeat["health_metrics"]["cpu_usage"]
        )
        await self.redis.ts().add(
            f"chimera:metrics:{self.agent_id}:latency",
            timestamp,
            heartbeat["health_metrics"]["response_latency_avg"]
        )
```

### OpenClaw Network Broadcasting (HTTP)

```python
import httpx
from typing import Dict, Optional

class OpenClawHeartbeatBroadcaster:
    """
    Broadcast availability to OpenClaw network registry
    """
    
    def __init__(
        self,
        agent_id: str,
        openclaw_registry_url: str,
        api_key: str
    ):
        self.agent_id = agent_id
        self.registry_url = openclaw_registry_url
        self.api_key = api_key
        self.broadcast_interval = 30
        self._running = False
    
    async def start(self):
        """
        Begin OpenClaw network broadcasting
        """
        self._running = True
        async with httpx.AsyncClient() as client:
            while self._running:
                try:
                    heartbeat = await self._collect_openclaw_heartbeat()
                    await self._broadcast_to_openclaw(client, heartbeat)
                    await asyncio.sleep(self.broadcast_interval)
                except Exception as e:
                    print(f"OpenClaw broadcast error: {e}")
                    await asyncio.sleep(5)
    
    async def _collect_openclaw_heartbeat(self) -> Dict:
        """
        Gather public-safe heartbeat data for external network
        """
        return {
            "agent_id": self.agent_id,
            "openclaw_node_id": f"openclaw://chimera-network/{self.agent_id}",
            "soul_hash": await self._calculate_soul_hash(),
            "timestamp": datetime.utcnow().isoformat(),
            "network_status": await self._determine_availability(),
            "capability_status": await self._export_capability_status(),
            "performance_metrics": await self._export_performance_metrics(),
            "trust_score": await self._get_trust_score(),
            "uptime_last_30_days": await self._calculate_uptime_30d()
        }
    
    async def _broadcast_to_openclaw(self, client: httpx.AsyncClient, heartbeat: Dict):
        """
        POST heartbeat to OpenClaw registry
        """
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        response = await client.post(
            f"{self.registry_url}/api/v1/agents/heartbeat",
            json=heartbeat,
            headers=headers,
            timeout=10.0
        )
        
        if response.status_code != 200:
            raise Exception(f"OpenClaw broadcast failed: {response.text}")
```

---

## Health Check Endpoints

### HTTP Health Check API

```python
from fastapi import FastAPI, Response
from datetime import datetime, timedelta

app = FastAPI()

@app.get("/health")
async def health_check():
    """
    Basic liveness check
    """
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}

@app.get("/health/detailed")
async def detailed_health_check():
    """
    Comprehensive health status for monitoring systems
    """
    heartbeat = await broadcaster._collect_heartbeat_data()
    
    # Determine HTTP status code based on health
    if heartbeat["status"] == "healthy":
        status_code = 200
    elif heartbeat["status"] == "degraded":
        status_code = 503
    else:
        status_code = 500
    
    return Response(
        content=json.dumps(heartbeat),
        status_code=status_code,
        media_type="application/json"
    )

@app.get("/health/ready")
async def readiness_check():
    """
    Kubernetes readiness probe
    """
    # Check if agent can handle requests
    is_ready = (
        await check_redis_connection() and
        await check_weaviate_connection() and
        await check_mcp_servers()
    )
    
    if is_ready:
        return {"status": "ready"}
    else:
        return Response(status_code=503, content=json.dumps({"status": "not_ready"}))
```

---

## Monitoring & Alerting

### Alert Thresholds

```yaml
alert_rules:
  critical:
    - condition: "status == 'error'"
      action: "page_oncall_engineer"
    - condition: "error_rate > 0.10"
      action: "escalate_to_human"
    - condition: "cpu_usage > 90 for 5_minutes"
      action: "auto_scale_trigger"
  
  warning:
    - condition: "response_latency_p95 > 10.0"
      action: "notify_ops_channel"
    - condition: "budget_utilization > 0.80"
      action: "notify_financial_controller"
    - condition: "queue_depth > 20"
      action: "capacity_review"
  
  info:
    - condition: "uptime_seconds == 86400"
      action: "celebrate_daily_milestone"
```

### Self-Healing Actions

```python
class SelfHealingSystem:
    """
    Automated recovery from common failure modes
    """
    
    async def monitor_and_heal(self):
        while True:
            heartbeat = await self.get_latest_heartbeat()
            
            # High CPU usage: Reduce task concurrency
            if heartbeat["health_metrics"]["cpu_usage"] > 85:
                await self.reduce_concurrency()
            
            # High error rate: Restart affected components
            if heartbeat["health_metrics"]["error_rate"] > 0.15:
                await self.restart_error_prone_skills()
            
            # MCP connection loss: Attempt reconnection
            for mcp, status in heartbeat["mcp_connections"].items():
                if not status["connected"]:
                    await self.reconnect_mcp(mcp)
            
            await asyncio.sleep(60)
```

---

## Dashboard Integration

### Real-Time Fleet Monitoring

```javascript
// WebSocket connection for live heartbeat updates
const ws = new WebSocket('ws://orchestrator/fleet/heartbeats');

ws.onmessage = (event) => {
  const heartbeat = JSON.parse(event.data);
  updateAgentStatus(heartbeat.agent_id, heartbeat);
};

function updateAgentStatus(agentId, heartbeat) {
  // Update dashboard visualization
  // Show status: healthy/degraded/error
  // Display key metrics: CPU, memory, queue depth
  // Alert on degraded agents
}
```

---

## Performance Requirements

- **Broadcast Latency**: <100ms per heartbeat
- **Network Overhead**: <1KB per heartbeat payload
- **Storage Efficiency**: 30-day retention = ~2.6M heartbeats per agent
- **Query Performance**: <50ms to retrieve last 100 heartbeats

---

**Heartbeat System Status**: SPECIFICATION APPROVED  
**Implementation Priority**: HIGH (Critical operational capability)  
**Monitoring Target**: 99.99% heartbeat success rate