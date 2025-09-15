# Comprehensive code review (Derived from Claude Code Github Action)

---
allowed-tools: Bash(git:*)
description: Review uncommitted changes
---

Perform a comprehensive code review of uncommitted changes using subagents for key areas:

- code-quality-reviewer
- performance-reviewer
- test-coverage-reviewer
- documentation-accuracy-reviewer
- security-code-reviewer

Instruct each to only provide noteworthy feedback. Once they finish, review the feedback and post only the feedback that you also deem noteworthy.

Provide feedback using inline comments for specific issues.
Use top-level comments for general observations or praise.
Keep feedback concise.

---
