# Project Chimera - Skills Architecture Documentation

**Document**: `skills/README.md`  
**Version**: 1.0.0  
**Last Updated**: February 5, 2026  
**Dependencies**: [specs/functional.md](../specs/functional.md), [specs/technical.md](../specs/technical.md)

## Overview

The Chimera Skills Architecture provides modular, reusable capabilities that Worker Agents can execute to accomplish atomic tasks. Skills are local computational modules that implement specific functionality aligned with the user stories defined in [specs/functional.md](../specs/functional.md).

**Skills vs. MCP Servers**:

- **Skills**: Local computational logic (video processing, trend analysis, content generation)
- **MCP Servers**: External API bridges (Twitter integration, Coinbase transactions, Weaviate queries)

## Skill Categories

### 1. Content Creation Pipeline

**Purpose**: Generate and process multimedia content for social platforms
**User Stories**: Epic 3 from [specs/functional.md](../specs/functional.md)

#### skill_download_video

**Location**: `skills/content_creation/download_video.py`
**Function**: Acquire video content from URLs, platforms, or user uploads

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "source_url": {
      "type": "string", 
      "format": "uri",
      "description": "URL of video to download"
    },
    "platform": {
      "type": "string",
      "enum": ["youtube", "tiktok", "instagram", "twitter", "direct_url"]
    },
    "quality_preference": {
      "type": "string", 
      "enum": ["highest", "1080p", "720p", "480p"],
      "default": "1080p"
    },
    "max_duration_seconds": {
      "type": "integer",
      "minimum": 1,
      "maximum": 300,
      "default": 60
    },
    "output_format": {
      "type": "string",
      "enum": ["mp4", "mov", "webm"],
      "default": "mp4"
    },
    "content_safety_check": {
      "type": "boolean",
      "default": true
    }
  },
  "required": ["source_url", "platform"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "video_file_path": {
      "type": "string",
      "description": "Local path to downloaded video file"
    },
    "metadata": {
      "type": "object",
      "properties": {
        "duration_seconds": {"type": "number"},
        "resolution": {"type": "string"},
        "file_size_mb": {"type": "number"},
        "format": {"type": "string"},
        "fps": {"type": "number"}
      }
    },
    "content_analysis": {
      "type": "object",
      "properties": {
        "safety_score": {"type": "number", "minimum": 0, "maximum": 1},
        "content_categories": {"type": "array", "items": {"type": "string"}},
        "detected_text": {"type": "string"},
        "audio_present": {"type": "boolean"}
      }
    },
    "confidence_score": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "description": "Success confidence in download and processing"
    },
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["video_file_path", "metadata", "confidence_score"]
}
```

#### skill_transcribe_audio

**Location**: `skills/content_creation/transcribe_audio.py`
**Function**: Convert speech to text with speaker identification and sentiment

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "audio_source": {
      "type": "string",
      "description": "Path to audio file or video file with audio track"
    },
    "language": {
      "type": "string",
      "default": "auto-detect",
      "description": "ISO 639-1 language code or 'auto-detect'"
    },
    "speaker_identification": {
      "type": "boolean",
      "default": true
    },
    "sentiment_analysis": {
      "type": "boolean", 
      "default": true
    },
    "timestamp_granularity": {
      "type": "string",
      "enum": ["word", "phrase", "sentence"],
      "default": "sentence"
    },
    "model_preference": {
      "type": "string",
      "enum": ["whisper-1", "whisper-large", "assembly-ai", "local"],
      "default": "whisper-1"
    }
  },
  "required": ["audio_source"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "transcription": {
      "type": "object",
      "properties": {
        "full_text": {"type": "string"},
        "segmented_text": {
          "type": "array",
          "items": {
            "type": "object", 
            "properties": {
              "text": {"type": "string"},
              "start_time": {"type": "number"},
              "end_time": {"type": "number"},
              "speaker_id": {"type": "string"},
              "confidence": {"type": "number"}
            }
          }
        }
      }
    },
    "analysis": {
      "type": "object",
      "properties": {
        "detected_language": {"type": "string"},
        "speaker_count": {"type": "integer"},
        "overall_sentiment": {
          "type": "object",
          "properties": {
            "polarity": {"type": "number", "minimum": -1, "maximum": 1},
            "subjectivity": {"type": "number", "minimum": 0, "maximum": 1},
            "emotions": {"type": "object"}
          }
        },
        "key_topics": {"type": "array", "items": {"type": "string"}},
        "content_warnings": {"type": "array", "items": {"type": "string"}}
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["transcription", "analysis", "confidence_score"]
}
```

#### skill_generate_caption

**Location**: `skills/content_creation/generate_caption.py`  
**Function**: Create platform-optimized social media captions with hashtags and mentions

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "content_context": {
      "type": "object",
      "properties": {
        "video_description": {"type": "string"},
        "transcription_summary": {"type": "string"},
        "visual_elements": {"type": "array", "items": {"type": "string"}},
        "target_audience": {"type": "string"},
        "content_goal": {"type": "string", "enum": ["engagement", "education", "entertainment", "promotion"]}
      },
      "required": ["content_goal"]
    },
    "persona_context": {
      "type": "object",
      "properties": {
        "persona_id": {"type": "string", "format": "uuid"},
        "voice_characteristics": {"type": "array", "items": {"type": "string"}},
        "expertise_domains": {"type": "array", "items": {"type": "string"}},
        "communication_style": {"type": "string"}
      },
      "required": ["persona_id"]
    },
    "platform_specs": {
      "type": "object",
      "properties": {
        "platform": {"type": "string", "enum": ["twitter", "instagram", "tiktok", "youtube_shorts"]},
        "max_length": {"type": "integer"},
        "hashtag_limit": {"type": "integer"},
        "mention_suggestions": {"type": "array", "items": {"type": "string"}}
      },
      "required": ["platform"]
    },
    "trend_context": {
      "type": "object",
      "properties": {
        "trending_topics": {"type": "array", "items": {"type": "string"}},
        "trending_hashtags": {"type": "array", "items": {"type": "string"}},
        "viral_formats": {"type": "array", "items": {"type": "string"}}
      }
    }
  },
  "required": ["content_context", "persona_context", "platform_specs"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "generated_caption": {
      "type": "object",
      "properties": {
        "main_text": {"type": "string"},
        "hashtags": {"type": "array", "items": {"type": "string"}},
        "mentions": {"type": "array", "items": {"type": "string"}},
        "call_to_action": {"type": "string"},
        "emoji_usage": {"type": "array", "items": {"type": "string"}}
      }
    },
    "optimization_data": {
      "type": "object", 
      "properties": {
        "character_count": {"type": "integer"},
        "engagement_score_prediction": {"type": "number"},
        "brand_safety_score": {"type": "number"},
        "trend_alignment_score": {"type": "number"},
        "persona_consistency_score": {"type": "number"}
      }
    },
    "alternative_versions": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "variant_type": {"type": "string"},
          "caption": {"type": "string"},
          "optimization_score": {"type": "number"}
        }
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["generated_caption", "optimization_data", "confidence_score"]
}
```

### 2. Market Intelligence

**Purpose**: Analyze market conditions, trends, and social sentiment  
**User Stories**: Epic 4 from [specs/functional.md](../specs/functional.md)

#### skill_analyze_trends

**Location**: `skills/market_intelligence/analyze_trends.py`
**Function**: Identify emerging topics with viral potential and engagement patterns

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "analysis_scope": {
      "type": "object",
      "properties": {
        "keywords": {"type": "array", "items": {"type": "string"}},
        "platforms": {"type": "array", "items": {"type": "string", "enum": ["twitter", "instagram", "tiktok", "youtube", "reddit"]}},
        "time_range": {"type": "string", "enum": ["1h", "6h", "24h", "7d", "30d"], "default": "24h"},
        "geographic_scope": {"type": "string", "default": "global"},
        "language_filter": {"type": "array", "items": {"type": "string"}}
      },
      "required": ["platforms"]
    },
    "analysis_depth": {
      "type": "string",
      "enum": ["surface", "deep", "comprehensive"],
      "default": "deep"
    },
    "content_categories": {
      "type": "array",
      "items": {"type": "string"},
      "description": "Filter trends by content category"
    },
    "minimum_velocity": {
      "type": "integer",
      "default": 1000,
      "description": "Minimum mentions/hour for trend consideration"
    }
  },
  "required": ["analysis_scope"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "trending_topics": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "topic": {"type": "string"},
          "virality_score": {"type": "number", "minimum": 0, "maximum": 1},
          "mention_velocity": {"type": "integer"},
          "sentiment_distribution": {
            "type": "object",
            "properties": {
              "positive": {"type": "number"},
              "neutral": {"type": "number"},
              "negative": {"type": "number"}
            }
          },
          "platform_breakdown": {"type": "object"},
          "related_hashtags": {"type": "array", "items": {"type": "string"}},
          "key_influencers": {"type": "array", "items": {"type": "string"}},
          "content_examples": {"type": "array", "items": {"type": "string"}},
          "predicted_lifespan": {"type": "string"}
        }
      }
    },
    "market_insights": {
      "type": "object",
      "properties": {
        "overall_sentiment": {"type": "string"},
        "content_opportunities": {"type": "array", "items": {"type": "string"}},
        "risk_factors": {"type": "array", "items": {"type": "string"}},
        "recommended_actions": {"type": "array", "items": {"type": "string"}}
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "data_freshness": {"type": "string", "format": "date-time"},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["trending_topics", "market_insights", "confidence_score", "data_freshness"]
}
```

#### skill_fetch_news

**Location**: `skills/market_intelligence/fetch_news.py`
**Function**: Gather and analyze news articles relevant to content strategy

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "search_parameters": {
      "type": "object",
      "properties": {
        "topics": {"type": "array", "items": {"type": "string"}},
        "sources": {"type": "array", "items": {"type": "string"}},
        "time_range": {"type": "string", "enum": ["1h", "6h", "24h", "7d"], "default": "24h"},
        "language": {"type": "string", "default": "en"},
        "relevance_threshold": {"type": "number", "minimum": 0, "maximum": 1, "default": 0.7}
      },
      "required": ["topics"]
    },
    "analysis_requirements": {
      "type": "object",
      "properties": {
        "sentiment_analysis": {"type": "boolean", "default": true},
        "key_entity_extraction": {"type": "boolean", "default": true},
        "content_categorization": {"type": "boolean", "default": true},
        "viral_potential_scoring": {"type": "boolean", "default": true}
      }
    },
    "content_filtering": {
      "type": "object",
      "properties": {
        "exclude_political": {"type": "boolean", "default": false},
        "exclude_nsfw": {"type": "boolean", "default": true},
        "brand_safety_filter": {"type": "boolean", "default": true}
      }
    }
  },
  "required": ["search_parameters"]
}
```

**Output Schema**:

```json
{
  "type": "object", 
  "properties": {
    "news_articles": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "title": {"type": "string"},
          "summary": {"type": "string"},
          "source": {"type": "string"},
          "published_at": {"type": "string", "format": "date-time"},
          "url": {"type": "string", "format": "uri"},
          "relevance_score": {"type": "number"},
          "sentiment_analysis": {
            "type": "object",
            "properties": {
              "overall_sentiment": {"type": "string"},
              "confidence": {"type": "number"}
            }
          },
          "key_entities": {"type": "array", "items": {"type": "string"}},
          "content_category": {"type": "string"},
          "viral_potential": {"type": "number"}
        }
      }
    },
    "aggregated_insights": {
      "type": "object",
      "properties": {
        "dominant_themes": {"type": "array", "items": {"type": "string"}},
        "sentiment_trends": {"type": "object"},
        "content_opportunities": {"type": "array", "items": {"type": "string"}},
        "timing_recommendations": {"type": "array", "items": {"type": "string"}}
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["news_articles", "aggregated_insights", "confidence_score"]
}
```

#### skill_sentiment_analysis

**Location**: `skills/market_intelligence/sentiment_analysis.py`
**Function**: Analyze emotional sentiment and public opinion across social platforms

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "content_sources": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "type": {"type": "string", "enum": ["text", "url", "social_handle", "hashtag"]},
          "value": {"type": "string"},
          "platform": {"type": "string", "enum": ["twitter", "instagram", "tiktok", "reddit", "youtube"]}
        }
      }
    },
    "analysis_parameters": {
      "type": "object",
      "properties": {
        "sentiment_granularity": {"type": "string", "enum": ["basic", "emotions", "aspects"], "default": "emotions"},
        "temporal_analysis": {"type": "boolean", "default": true},
        "comparative_analysis": {"type": "boolean", "default": false},
        "demographic_breakdown": {"type": "boolean", "default": false}
      }
    },
    "target_context": {
      "type": "object",
      "properties": {
        "brand_name": {"type": "string"},
        "product_name": {"type": "string"},
        "campaign_hashtags": {"type": "array", "items": {"type": "string"}},
        "competitor_analysis": {"type": "array", "items": {"type": "string"}}
      }
    }
  },
  "required": ["content_sources"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "sentiment_analysis": {
      "type": "object",
      "properties": {
        "overall_sentiment": {
          "type": "object", 
          "properties": {
            "polarity": {"type": "number", "minimum": -1, "maximum": 1},
            "subjectivity": {"type": "number", "minimum": 0, "maximum": 1},
            "confidence": {"type": "number", "minimum": 0, "maximum": 1}
          }
        },
        "emotion_breakdown": {
          "type": "object",
          "properties": {
            "joy": {"type": "number"},
            "sadness": {"type": "number"},
            "anger": {"type": "number"},
            "fear": {"type": "number"},
            "surprise": {"type": "number"},
            "trust": {"type": "number"}
          }
        },
        "temporal_trends": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "timestamp": {"type": "string", "format": "date-time"},
              "sentiment_score": {"type": "number"},
              "volume": {"type": "integer"}
            }
          }
        }
      }
    },
    "insights": {
      "type": "object",
      "properties": {
        "sentiment_drivers": {"type": "array", "items": {"type": "string"}},
        "risk_indicators": {"type": "array", "items": {"type": "string"}},
        "opportunity_areas": {"type": "array", "items": {"type": "string"}},
        "recommended_responses": {"type": "array", "items": {"type": "string"}}
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["sentiment_analysis", "insights", "confidence_score"]
}
```

### 3. Social Engagement

**Purpose**: Manage authentic interactions and optimize social presence
**User Stories**: Epic 5 from [specs/functional.md](../specs/functional.md)

#### skill_reply_comments  

**Location**: `skills/social_engagement/reply_comments.py`
**Function**: Generate contextually appropriate responses to mentions and comments

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "interaction_context": {
      "type": "object",
      "properties": {
        "platform": {"type": "string", "enum": ["twitter", "instagram", "tiktok", "youtube"]},
        "interaction_type": {"type": "string", "enum": ["mention", "comment", "direct_message", "reply"]},
        "original_content": {"type": "string"},
        "user_context": {
          "type": "object",
          "properties": {
            "username": {"type": "string"},
            "follower_count": {"type": "integer"},
            "interaction_history": {"type": "string"},
            "sentiment_towards_brand": {"type": "string"}
          }
        }
      },
      "required": ["platform", "interaction_type", "original_content"]
    },
    "response_parameters": {
      "type": "object",
      "properties": {
        "persona_id": {"type": "string", "format": "uuid"},
        "response_tone": {"type": "string", "enum": ["professional", "casual", "humorous", "empathetic"]},
        "max_length": {"type": "integer"},
        "include_call_to_action": {"type": "boolean", "default": false},
        "escalation_topics": {"type": "array", "items": {"type": "string"}}
      },
      "required": ["persona_id"]
    },
    "brand_guidelines": {
      "type": "object",
      "properties": {
        "approved_topics": {"type": "array", "items": {"type": "string"}},
        "restricted_topics": {"type": "array", "items": {"type": "string"}},
        "brand_voice_keywords": {"type": "array", "items": {"type": "string"}},
        "crisis_response_triggers": {"type": "array", "items": {"type": "string"}}
      }
    }
  },
  "required": ["interaction_context", "response_parameters"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "generated_response": {
      "type": "object",
      "properties": {
        "response_text": {"type": "string"},
        "response_type": {"type": "string", "enum": ["direct_answer", "question", "appreciation", "redirect", "escalation"]},
        "emoji_usage": {"type": "array", "items": {"type": "string"}},
        "mentions": {"type": "array", "items": {"type": "string"}},
        "hashtags": {"type": "array", "items": {"type": "string"}}
      }
    },
    "escalation_assessment": {
      "type": "object",
      "properties": {
        "requires_human_review": {"type": "boolean"},
        "escalation_reason": {"type": "string"},
        "sensitivity_score": {"type": "number", "minimum": 0, "maximum": 1},
        "brand_risk_level": {"type": "string", "enum": ["low", "medium", "high"]}
      }
    },
    "engagement_optimization": {
      "type": "object",
      "properties": {
        "predicted_engagement": {"type": "number"},
        "persona_consistency": {"type": "number"},
        "brand_alignment": {"type": "number"},
        "authenticity_score": {"type": "number"}
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["generated_response", "escalation_assessment", "confidence_score"]
}
```

#### skill_schedule_posts

**Location**: `skills/social_engagement/schedule_posts.py`
**Function**: Optimize posting frequency and timing for maximum engagement

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "content_queue": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "content_id": {"type": "string", "format": "uuid"},
          "content_type": {"type": "string", "enum": ["text", "image", "video", "story"]},
          "platform": {"type": "string", "enum": ["twitter", "instagram", "tiktok", "youtube_shorts"]},
          "priority": {"type": "string", "enum": ["high", "medium", "low"]},
          "content_preview": {"type": "string"},
          "estimated_engagement": {"type": "number"}
        }
      }
    },
    "scheduling_parameters": {
      "type": "object",
      "properties": {
        "persona_id": {"type": "string", "format": "uuid"},
        "time_zone": {"type": "string", "default": "UTC"},
        "scheduling_window": {
          "type": "object",
          "properties": {
            "start_date": {"type": "string", "format": "date"},
            "end_date": {"type": "string", "format": "date"},
            "daily_post_limit": {"type": "integer", "default": 3}
          }
        },
        "optimization_goals": {"type": "array", "items": {"type": "string", "enum": ["reach", "engagement", "conversions", "brand_awareness"]}}
      },
      "required": ["persona_id"]
    },
    "audience_insights": {
      "type": "object",
      "properties": {
        "peak_activity_hours": {"type": "array", "items": {"type": "integer"}},
        "audience_time_zones": {"type": "object"},
        "content_type_preferences": {"type": "object"},
        "historical_engagement_data": {"type": "object"}
      }
    }
  },
  "required": ["content_queue", "scheduling_parameters"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "optimized_schedule": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "content_id": {"type": "string", "format": "uuid"},
          "scheduled_datetime": {"type": "string", "format": "date-time"},
          "platform": {"type": "string"},
          "predicted_metrics": {
            "type": "object",
            "properties": {
              "estimated_reach": {"type": "integer"},
              "estimated_engagement": {"type": "number"},
              "optimal_score": {"type": "number"}
            }
          },
          "reasoning": {"type": "string"}
        }
      }
    },
    "scheduling_insights": {
      "type": "object",
      "properties": {
        "content_distribution_balance": {"type": "object"},
        "platform_optimization": {"type": "object"},
        "audience_timing_alignment": {"type": "number"},
        "frequency_optimization": {"type": "string"}
      }
    },
    "alternative_schedules": {
      "type": "array", 
      "items": {
        "type": "object",
        "properties": {
          "scenario_name": {"type": "string"},
          "schedule": {"type": "array"},
          "predicted_performance": {"type": "object"}
        }
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["optimized_schedule", "scheduling_insights", "confidence_score"]
}
```

#### skill_analyze_metrics

**Location**: `skills/social_engagement/analyze_metrics.py`
**Function**: Measure performance and provide actionable insights for content optimization

**Input Schema**:

```json
{
  "type": "object",
  "properties": {
    "analysis_scope": {
      "type": "object", 
      "properties": {
        "persona_id": {"type": "string", "format": "uuid"},
        "platforms": {"type": "array", "items": {"type": "string"}},
        "time_period": {
          "type": "object",
          "properties": {
            "start_date": {"type": "string", "format": "date"},
            "end_date": {"type": "string", "format": "date"}
          }
        },
        "content_filters": {
          "type": "object",
          "properties": {
            "content_types": {"type": "array", "items": {"type": "string"}},
            "campaigns": {"type": "array", "items": {"type": "string"}},
            "hashtags": {"type": "array", "items": {"type": "string"}}
          }
        }
      },
      "required": ["persona_id", "platforms", "time_period"]
    },
    "analysis_depth": {
      "type": "string",
      "enum": ["summary", "detailed", "comprehensive"],
      "default": "detailed"
    },
    "benchmarking": {
      "type": "object",
      "properties": {
        "competitor_comparison": {"type": "boolean", "default": false},
        "industry_benchmarks": {"type": "boolean", "default": true},
        "historical_comparison": {"type": "boolean", "default": true}
      }
    }
  },
  "required": ["analysis_scope"]
}
```

**Output Schema**:

```json
{
  "type": "object",
  "properties": {
    "performance_metrics": {
      "type": "object",
      "properties": {
        "content_performance": {
          "type": "object",
          "properties": {
            "total_posts": {"type": "integer"},
            "total_reach": {"type": "integer"},
            "total_impressions": {"type": "integer"},
            "total_engagement": {"type": "integer"},
            "avg_engagement_rate": {"type": "number"},
            "top_performing_content": {"type": "array"},
            "underperforming_content": {"type": "array"}
          }
        },
        "audience_insights": {
          "type": "object",
          "properties": {
            "follower_growth": {"type": "integer"},
            "audience_demographics": {"type": "object"},
            "engagement_patterns": {"type": "object"},
            "peak_activity_times": {"type": "array"}
          }
        },
        "platform_breakdown": {"type": "object"}
      }
    },
    "actionable_insights": {
      "type": "object",
      "properties": {
        "content_recommendations": {"type": "array", "items": {"type": "string"}},
        "timing_optimizations": {"type": "array", "items": {"type": "string"}},
        "audience_growth_strategies": {"type": "array", "items": {"type": "string"}},
        "platform_specific_advice": {"type": "object"}
      }
    },
    "trend_analysis": {
      "type": "object",
      "properties": {
        "performance_trends": {"type": "object"},
        "content_type_trends": {"type": "object"},
        "seasonal_patterns": {"type": "object"},
        "predictive_insights": {"type": "array", "items": {"type": "string"}}
      }
    },
    "confidence_score": {"type": "number", "minimum": 0, "maximum": 1},
    "processing_time_ms": {"type": "integer"},
    "cost_usd": {"type": "number"}
  },
  "required": ["performance_metrics", "actionable_insights", "confidence_score"]
}
```

## Skill Interface Standards

### Base Skill Structure

All skills must implement this Python interface:

```python
from abc import ABC, abstractmethod
from typing import Dict, Any
from pydantic import BaseModel, Field
import uuid
import time
from datetime import datetime

class SkillBase(ABC):
    """
    Base class for all Chimera skills.
    
    Implements common functionality:
    - Input/output validation
    - Confidence scoring
    - Performance tracking
    - Error handling
    """
    
    def __init__(self):
        self.skill_id = str(uuid.uuid4())
        self.created_at = datetime.utcnow()
    
    @abstractmethod
    async def execute(self, input_data: BaseModel) -> BaseModel:
        """
        Execute the skill with validated input and return validated output.
        
        Must:
        1. Validate input against skill-specific schema
        2. Perform skill logic with error handling
        3. Calculate confidence score based on success metrics
        4. Return output matching skill-specific schema
        """
        pass
    
    @abstractmethod
    def get_input_schema(self) -> Dict[str, Any]:
        """Return JSON schema for skill input validation."""
        pass
    
    @abstractmethod 
    def get_output_schema(self) -> Dict[str, Any]:
        """Return JSON schema for skill output validation."""
        pass
    
    def calculate_confidence(self, success_metrics: Dict[str, float]) -> float:
        """
        Calculate confidence score based on skill-specific success metrics.
        
        Args:
            success_metrics: Dict of metric_name -> score (0.0 to 1.0)
            
        Returns:
            Overall confidence score (0.0 to 1.0)
        """
        if not success_metrics:
            return 0.0
            
        weights = {
            'data_quality': 0.3,
            'processing_success': 0.25, 
            'output_completeness': 0.25,
            'performance': 0.2
        }
        
        weighted_score = sum(
            score * weights.get(metric, 0.1) 
            for metric, score in success_metrics.items()
        )
        
        return min(max(weighted_score, 0.0), 1.0)
```

### Error Handling Standards

```python
from typing import Optional
from enum import Enum

class SkillErrorType(Enum):
    INPUT_VALIDATION = "input_validation"
    EXTERNAL_API_FAILURE = "external_api_failure" 
    PROCESSING_TIMEOUT = "processing_timeout"
    INSUFFICIENT_RESOURCES = "insufficient_resources"
    CONTENT_SAFETY_VIOLATION = "content_safety_violation"
    RATE_LIMIT_EXCEEDED = "rate_limit_exceeded"

class SkillError(Exception):
    def __init__(self, error_type: SkillErrorType, message: str, recoverable: bool = True):
        self.error_type = error_type
        self.message = message
        self.recoverable = recoverable
        super().__init__(f"{error_type.value}: {message}")

# Usage in skills:
try:
    result = await external_api_call()
except APITimeout:
    raise SkillError(
        SkillErrorType.PROCESSING_TIMEOUT,
        "External API call timed out after 30 seconds",
        recoverable=True
    )
```

## Performance Requirements

### Skills Performance Targets

From [specs/_meta.md](../specs/_meta.md) and [specs/functional.md](../specs/functional.md):

| Skill Category | Max Execution Time | Memory Limit | Cost Limit |
|----------------|-------------------|--------------|------------|
| Content Creation | 45 seconds | 2GB | $8 USD |
| Market Intelligence | 15 seconds | 1GB | $3 USD |  
| Social Engagement | 5 seconds | 512MB | $2 USD |

### Quality Metrics

- **Confidence Score**: All skills must return confidence ≥ 0.70 for auto-approval
- **Success Rate**: >95% successful execution under normal conditions
- **Data Quality**: Input validation catches >99% of malformed requests
- **Error Recovery**: Graceful handling of external service failures

## Integration with Agent Types

### Worker Agent Integration

```python
# Example: Content Creation Worker using skills
from chimera.skills.content_creation import skill_download_video, skill_transcribe_audio, skill_generate_caption

class ContentCreationWorker:
    async def execute_content_pipeline(self, task: ChimeraTask) -> GeneratedContent:
        """
        Implementation of User Story 3.1 from specs/functional.md
        """
        # Step 1: Download video content
        download_result = await skill_download_video.execute({
            "source_url": task.context["source_url"],
            "platform": task.context["platform"]
        })
        
        if download_result.confidence_score < 0.70:
            # Escalate to Judge Agent for review
            return await self.escalate_low_confidence(task, download_result)
        
        # Step 2: Transcribe audio
        transcription_result = await skill_transcribe_audio.execute({
            "audio_source": download_result.video_file_path
        })
        
        # Step 3: Generate optimized caption
        caption_result = await skill_generate_caption.execute({
            "content_context": {
                "video_description": transcription_result.analysis["key_topics"],
                "content_goal": task.context["goal"]
            },
            "persona_context": await get_persona_context(task.context["persona_id"]),
            "platform_specs": {"platform": task.context["platform"]}
        })
        
        return GeneratedContent(
            content_type="video_post",
            content_data=caption_result.generated_caption,
            confidence_score=min(download_result.confidence_score, 
                               transcription_result.confidence_score,
                               caption_result.confidence_score)
        )
```

## Development & Testing Guidelines

### Skill Development Workflow

1. **Define Specification**: Reference user story from [specs/functional.md](../specs/functional.md)
2. **Create Schemas**: Input/output JSON schemas with validation
3. **Write Failing Tests**: TDD approach proving specification requirements
4. **Implement Logic**: Core skill functionality with error handling
5. **Validate Performance**: Ensure execution time and quality metrics
6. **Integration Testing**: Test with Worker Agents and MCP servers

### Test-Driven Development for Skills

```python
# tests/skills/test_skill_analyze_trends.py
import pytest
from chimera.skills.market_intelligence.analyze_trends import SkillAnalyzeTrends

class TestSkillAnalyzeTrends:
    def test_trend_analysis_schema_compliance(self):
        """Test that analyze_trends returns data matching specs/technical.md schema"""
        # This test should FAIL until skill is correctly implemented
        skill = SkillAnalyzeTrends()
        
        input_data = {
            "analysis_scope": {
                "platforms": ["twitter", "tiktok"],
                "time_range": "24h"
            }
        }
        
        result = await skill.execute(input_data)
        
        # Validate exact schema compliance
        assert "trending_topics" in result
        assert "confidence_score" in result
        assert 0.0 <= result["confidence_score"] <= 1.0
        
        # Validate trending topics structure
        for topic in result["trending_topics"]:
            assert "virality_score" in topic
            assert isinstance(topic["virality_score"], float)
            assert 0.0 <= topic["virality_score"] <= 1.0
```

---

**Next Steps**:

1. Implement Python skill modules following the interface standards
2. Create tooling strategy documentation for MCP servers  
3. Build test suite for all skill contracts
4. Integration with Worker Agent implementations

**Validation**: This skills documentation provides complete I/O contracts that agents can implement to fulfill all user stories from [specs/functional.md](../specs/functional.md). All 9 skills align with the "Autonomy with Bounded Risk" principle and confidence-based HITL routing requirements.
