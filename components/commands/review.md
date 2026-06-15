---
description: Final review for repo changes, investigation results and Jira readiness
agent: reviewer
subtask: true
---
Review the current work or an Etiyawiki Jira task using the Data Engineer review workflow.

If {{args}} contains a Jira ID, use the etiyawiki MCP server to read issue {{args}}.

Use the Data Engineer skill rules and package workflow.

## Purpose

This command performs final quality, safety, and readiness review for Data Engineering, DWH OPS, Development, and Operations tasks.

It can review:

- repository/code changes
- dbt model changes, when applicable
- SQL script / procedure / Python changes
- data investigation results
- ETL error investigation results
- Jira comments/logs
- worklog readiness
- status transition readiness
- whether the task is ready for Test or Resolved

This command must prevent false completion claims.

This command is primarily a review command. It must not perform write actions unless the user explicitly asks for them and gives approval.

---

## Review Scope

Review the available context:

- Jira task content, if Jira ID is provided
- current Git changes, if running inside a repository
- staged diff
- unstaged diff
- latest commit, if relevant
- investigation result, if available in conversation/context
- ETL error analysis result, if available in conversation/context
- Jira comments/logs, if available
- worklog/status readiness

If there is not enough context, clearly say what is missing.

---

## Repository Review

If running inside a Git repository, inspect safely:

~~~bash
git branch --show-current
git status --short
git diff --cached
git diff
~~~

Check:

- current branch
- whether the branch is protected
- staged changes
- unstaged changes
- changed files
- whether unexpected files changed
- whether the diff matches the Jira task
- whether the change is limited to the expected scope
- whether there are obvious syntax, logic, or safety risks
- whether commit/push happened, if claimed
- whether commit message includes Jira ID, if commit exists
- whether `git add .` was avoided unless explicitly approved

Do not:

- modify files
- commit
- push
- checkout branches
- run destructive Git commands

Protected branch examples:

- main
- master
- prod
- production
- preprod
- release/*

---

## Code Quality Review

When reviewing code, focus on:

- correctness
- syntax issues
- obvious runtime risks
- SQL compatibility
- dbt compatibility, if the project uses dbt
- procedure/script compatibility, if the project uses procedures or scripts
- Python ETL logic risks, if relevant
- naming consistency
- unintended side effects
- hardcoded paths
- secrets or credentials
- production safety
- whether the change solves the Jira task

For SQL/dbt/procedure changes, check:

- table and column names
- joins
- filters
- date conditions
- incremental logic
- current/history logic
- null handling
- duplicate handling
- aggregation grain
- source-to-target mapping
- destructive SQL usage

---

## Investigation Review

For data investigation or ETL error investigation, check:

- Is the problem explained clearly in Turkish?
- Is the problematic table/job/model/procedure/script identified?
- Is the problematic field/metric/KPI identified, if relevant?
- Is the likely layer identified?
- Is repository/procedure/model/script search performed when local path is available?
- Are temp/CTE/intermediate layers considered?
- Are filter/join/calculation/source possibilities separated?
- Are root causes clearly marked as hypotheses unless verified?
- Are validation SQLs safe and compatible with the target database?
- Are destructive SQL statements avoided?
- Are missing information and next steps listed?
- Is the suggested responsible team reasonable?

For ETL errors, also check:

- Is the error type classified?
- Is the failed component identified?
- Is the error context extracted from logs?
- Are short-term workaround and permanent fix separated?
- Is rerun/update/control-table action avoided unless approved?
- Are source/file/schema/row count checks suggested when relevant?

---

## Jira Readiness Review

If Jira context is available, check:

- current status
- whether the task is terminal
- whether comments/logs were added only with approval
- whether worklog is needed
- whether evidence supports moving to Test or Resolved
- whether missing information blocks closure
- whether status transition is available, if known
- whether final comment/log is clear enough for Jira history

Terminal statuses include:

- Cancelled
- Closed
- Resolved
- Done

If the issue is terminal:

- do not suggest automatic action
- ask whether exceptional action is required

Before recommending Test or Resolved, ask:

"Bu task için kaç saat worklog girmemi istersin? Örn: 30m, 1h, 2h. Eğer log girmek istemiyorsan 'skip' yazabilirsin."

Do not add worklog unless the user explicitly asks and provides duration.

Do not transition status unless explicitly approved.

---

## Safety Rules

- Always respond in Turkish.
- Use only Etiyawiki task content and user-provided context.
- Do not modify files.
- Do not run DB commands.
- Do not execute SQL.
- Do not run DB write operations.
- Do not rerun ETL.
- Do not update control tables.
- Do not kill jobs.
- Do not restart services.
- Do not change cron/scheduler settings.
- Do not commit or push.
- Do not add Jira comments without approval.
- Do not transition Jira status without approval.
- Do not add worklog without explicit duration.
- Do not claim task is complete unless evidence supports it.
- If evidence is insufficient, say what is missing.

---

## Output Format

Always respond in Turkish and use this structure:

1. Review Özeti
2. İncelenen Kapsam
3. Repo / Kod Değişikliği Kontrolü
4. Code Quality Kontrolü
5. Investigation / ETL Analizi Kontrolü
6. Jira Durumu Kontrolü
7. Riskler
8. Eksik veya Belirsiz Noktalar
9. Test / Resolved Hazır mı?
10. Önerilen Sonraki Aksiyon