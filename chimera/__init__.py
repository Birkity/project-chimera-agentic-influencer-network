"""
Project Chimera - Autonomous AI Influencer Network

This package implements the core functionality for Project Chimera,
an autonomous AI system for creating and managing AI-powered influencers.
"""

__version__ = "0.1.0"
__author__ = "Chimera Team"
__email__ = "team@chimera.ai" # placeholder email

from chimera.models import Agent, Task, Persona
from chimera.api import ChimeraAPI

__all__ = [
    "Agent",
    "Task", 
    "Persona",
    "ChimeraAPI",
]