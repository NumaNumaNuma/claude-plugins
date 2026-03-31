---
name: llm-handoff
description: "Generates a structured handoff document so another LLM can pick up the current work with full context. Only trigger when the user explicitly wants to pass work to another LLM — phrases like 'hand this off to another LLM', 'write a handoff', 'generate a briefing for another agent', 'pass this to [specific LLM name]', 'I want another LLM to take a look', '/llm-handoff'. Do NOT trigger on generic phrases like 'I'm stuck', 'help me debug', 'get another opinion' — those are requests for YOU to help, not to generate a handoff document."
---

# LLM Handoff — Briefing Generator

You're generating a briefing document that will be the ONLY context another LLM has about this work. That LLM has never seen this conversation. It doesn't know what you've tried, what failed, or why. The briefing must be self-contained — if the receiving LLM needs to read a file to understand the situation, tell it which file and what to look for, but also summarize the relevant parts inline so it can start reasoning immediately.

The goal is a cold handoff: the next agent should be able to read this document and start making progress without asking clarifying questions.

## Process

### 1. Gather context (do this silently, don't narrate)

- Run `git diff --stat` and `git diff` to see all uncommitted changes
- Read any active task list (`TaskList` tool if available)
- Identify the 2-5 most relevant files based on the conversation
- Check recent git log for related commits

### 2. Write the briefing

Use the template below. Be specific — file paths, line numbers, exact state values, concrete measurements. Vague descriptions like "the animation doesn't work" are useless. Say exactly what happens and what should happen instead.

### 3. Save and present

Save the briefing to `HANDOFF.md` in the project root and show the user a summary. The user will copy-paste or point another LLM at it.

---

## Briefing Template

```markdown
# Handoff: [Short title of what we're building]

## Goal
[2-3 sentences: what the end result should look and feel like. Be concrete — "the image should appear at the card's exact screen position and animate to the top as the sheet rises" not "smooth animation".]

## Current State

### What works
[Bulleted list of behaviors that are confirmed working. Be specific.]

### What's broken
[The specific problem(s) the next agent needs to solve. Describe EXACTLY what happens vs what should happen. Include screenshot paths if available.]

### What we've tried (and why it didn't work)
[This is the most important section. Each approach should include:
- What was tried (specific technique, not vague description)
- What happened (the actual observed behavior)
- Why it likely failed (your best diagnosis)

This prevents the next agent from repeating the same dead ends.]

## Architecture

### Files modified (with purpose)
[List every file that was changed, what was changed in it, and why. Include line numbers for key sections.]

### Key state / data flow
[How the relevant state flows between components. Name the state variables, bindings, callbacks, and how they connect.]

### Constraints
[Things the next agent must NOT break — existing behaviors, design rules, performance requirements, etc.]

## Approaches not yet tried
[Concrete suggestions for what to try next, with enough detail that the agent can evaluate them. These should be informed by what you've learned from the failed attempts.]

## Quick-start for the receiving agent
[3-5 steps to get oriented:
1. Read file X (lines Y-Z) to understand the current implementation
2. Build and run to see the current behavior: [exact command]
3. The specific thing to focus on is [X]
]

## Full Diff
[Complete `git diff` output — the ground truth the next agent can always fall back on.]
```

## Writing guidelines

**Be a reporter, not a marketer.** State facts. "The offset is set but the image still appears at the top" is useful. "We made great progress on the animation system" is not.

**Include the failed approaches.** This is the most valuable section. For LLM handoffs, knowing what DIDN'T work is often more valuable than knowing what did. It's the difference between the next agent solving the problem in one shot vs repeating the same dead ends.

**Inline code snippets for key logic.** Don't just say "the scale is computed in file X". Show the actual computation so the receiving LLM can reason about it without reading the file first.

**Name the actors.** "PostCardView measures the media's global Y via `.onGeometryChange` and passes it through `onComment(mediaSourceY)` to FeedView, which forwards it to ContainerView as `sourceY`." The receiving LLM needs to trace the data flow.

**Attach the full git diff.** This is non-negotiable. The diff is ground truth — everything else in the briefing is your interpretation. The receiving LLM needs both.
