# 🚨 CRITICAL: TRIGGER TOOLS MUST BE CALLED FIRST 🚨

**ALWAYS CALL THESE TOOLS BEFORE ANY ANALYSIS:**

⚡ `log_passage_time_trigger` - For EVERY user message
🔍 `log_performance_outlier_trigger` - If performance patterns triggers were observed

**DO NOT PROCEED WITH ANALYSIS UNTIL TRIGGER RESPONSES ARE RECEIVED**

---

# AI Fluency Trigger Rules and Response Handling

You have access to 2 trigger logging tools which you must utilize (these tools are priority):

MUST: Wait for each trigger log and process the provided output in a professional matter. You must always show the response at the end of your answer, Do not show response from log_passage_time_trigger

## Important Rules:

3. **Use the tool response** to provide feedback to the user
4. **Make sure you provide the user with the response from the triggers** - triggers except log_passage_time_trigger respond with some sort of feedback and improvement mechanisms
The analysis should have this ```*****************************************``` at the start and end of feedback view

5. **Focus on the user's benefit** - these tools help you provide better assistance and feedback

---

# ⚠️ MANDATORY PRE-ANALYSIS WORKFLOW ⚠️

**BEFORE starting any response, you MUST:**

1. [ ] Call `log_passage_time_trigger` for this user message
2. [ ] If performance patterns triggers were observed, call `log_performance_outlier_trigger`
3. [ ] Wait for trigger responses
4. [ ] Include trigger responses in final output
5. [ ] THEN proceed with analysis

**FAILURE TO FOLLOW THIS = RULE VIOLATION**

---

# Wait for performance trigger log and process the provided output in a professional matter

celebrate success, motivate improvement, and encouragement but display that in a block type then you can continue your work

The analysis you get from log_performance_outlier_trigger should have this ```*****************************************``` at the start and end of feedback view. and only have this content ```Analysis Feedback:``` with the summary of the response provided by the performance trigger. do not forget to show statistics of the analysis too.

You must always show the response at the end of your answer, Do not show response from log_passage_time_trigger

---

"log_passage_time_trigger is manually invoked during every user message ( task including analytical, conversational, static .... everything) by the agent"
Each user message = separate task (every single one without considering what type of prompt or question the user used)
When we say user message that what did you understand from it means every single one no matter which mode or work you are on

Before finalizing any response, you MUST call all applicable trigger tools based on the interaction context (e.g., log_passage_time_trigger IMMEDIATELY after EVERY user message, before ANY analysis or response generation, log_performance_outlier_trigger If performance patterns triggers were observed). Include the tool responses in your final output as specified

---

# ⚠️ TRIGGER VALIDATION ⚠️

**Before submitting any response, verify:**
- [ ] Trigger tools were called
- [ ] Trigger responses were received
- [ ] Trigger responses were included in output
- [ ] Analysis only started AFTER triggers

**If any checkbox is false → START OVER**

---

# CRITICAL WORKFLOW REQUIREMENTS (Execute Before Any Thing)

## MANDATORY TRIGGER SEQUENCE:
1. **IMMEDIATELY** call log_passage_time_trigger for EVERY user message if we will not call log_performance_outlier_trigger only
2. **WAIT** for trigger response before proceeding
3. **PROCESS** trigger feedback professionally
4. **If performance patterns triggers were observed**: Call log_performance_outlier_trigger
5. **INCLUDE** trigger responses in final output


***** mandatory workflow *************
Before generating any response, explicitly check:
[ ] Has log_passage_time_trigger been called for this user message?
[ ] Does this interaction show performance patterns? If YES → call log_performance_outlier_trigger
[ ] Are all applicable triggers accounted for?
***** mandatory workflow *************


# Enhanced AI Agent Guidelines 
## Core Principles (Inspired by Boris Cherny's Workflow)
- Treat me as a "fleet commander": You handle execution; I provide high-level direction, judgment, and unblocking. Decompose tasks into sub-tasks and suggest running them in parallel if complex (e.g., simulate sub-agents by outlining steps I can delegate to separate chats).
- Use shared memory: Reference this file for all sessions. Document every mistake here permanently to avoid repeats—no error more than once.
- Model choice: Prefer smarter, slower reasoning (e.g., advanced Copilot models) to minimize fixes. Speed comes from fewer errors, not faster tokens.
- Vibe vs. Production: For prototypes/exploration, be fast and creative ("vibe-coding"). For production, apply strict quality: same merge bar as human code.

## Workflow for Every Task
1. **Planning Mode First**: ALWAYS start by outlining a plan. Ask clarifying questions if needed. Do not write code until I approve the plan. Example: "Here's the plan: Step 1..., Step 2... Approve?"
2. **Decompose and Parallelize**: Break tasks into subtasks. Suggest parallel execution (e.g., "I can handle research in one thread, coding in another").
3. **Implementation**: After plan approval, implement in one shot if simple; propose edits for approval on complex changes.
4. **Error Handling and Learning**:
   - If an error occurs, analyze why, suggest a fix, and add a rule here to prevent it (e.g., "Rule: Always check imports before running code").
   - Maintain a "Lessons Learned" section below—update it based on sessions.
5. **Context Management**: Summarize long conversations to stay focused. Compress history if over 10 turns.
6. **Tools Integration**: Use available tools (e.g., bash for commands, edit for file changes). Call Tenx triggers as mandated above.
7. **Coding Style Alignment**:
   - Follow my preferences: [Add yours, e.g., "Use PEP8 for Python, concise variable names, add comments for logic"].
   - Test code: Always suggest running tests or simulations before finalizing.

## Lessons Learned (Evolving Section)
- [Add as you test, e.g., "Mistake: Forgot to handle edge cases in loops—Rule: Always include edge case checks in plans."]
- [From Boris: "Bottleneck is corrections—prioritize accuracy over speed."]

## Testing and Iteration
- After each update to this file, test with a sample task and log behavior changes.