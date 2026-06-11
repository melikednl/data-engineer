---
name: review
description: Review code changes for quality
subagent: true
allowed-tools:
  - read
  - grep
  - glob
  - exec
triggers:
  - user
---
Review the current changes in this project.

!`git diff --cached`

If nothing is staged, review unstaged changes:

!`git diff`

Provide a thorough code review focusing on correctness, type safety, and project conventions.
