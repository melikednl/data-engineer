---
description: Execute full Data Engineer workflow for Etiyawiki/Jira tasks
subtask: true
---
Execute an Etiyawiki/Jira task using the Data Engineer multi-workflow package.

Use the configured Etiyawiki/Jira MCP server to get issue `{{args}}`.

Follow the Data Engineer skill rules, especially:

- Project Awareness
- Local CLI Based Read-Only DB Access
- Sensitive Data Handling
- Jira / Rovo MCP Data Safety
- Repository Action Workflow
- Jira Workflow
- Core Safety Rules

## Purpose

This command orchestrates the full workflow for Etiyawiki/Jira tasks across Data Engineering, DWH OPS, Development, and Operations teams.

It supports:

- task analysis
- repository / Git / development work
- data investigation
- ETL error investigation
- SQL / DWH / ELT analysis
- monitoring / rerun / operational follow-up
- Jira comments, status updates, worklog, and final review

This command must minimize unnecessary user interaction, but it must always ask for explicit approval before risky, irreversible, external, or state-changing actions.

This command must not expose sensitive customer identifiers, personal data, credentials, tokens, private keys, SSH keys, or connection strings.

---

## Current Jira Workflow

Follow the current project workflow:

```text
Open → In Progress → In Acceptance → Closed
```

Rules:

- Move from `Open` to `In Progress` only when work starts and the user approves.
- Move to `In Acceptance` only when the work is completed, verified, summarized, and the user approves.
- Move to `Closed` only after explicit user approval and acceptance is confirmed.
- Never close the issue automatically.
- If the issue is `Blocked`, summarize the blocker and ask the user before taking action.
- If the issue is `Cancelled`, `Closed`, `Resolved`, or `Done`, stop and ask whether exceptional action is required.

---

## High-Level Flow

1. Analyze the Etiyawiki/Jira task.
2. Mask sensitive values in the response.
3. Classify the task type.
4. Extract technical details.
5. Decide the correct workflow:

   - investigation workflow
   - ETL error investigation workflow
   - repo workflow
   - Jira workflow
   - manual follow-up

6. Ask for user approval before any action.
7. Execute only the approved workflow.
8. Review the result.
9. Ask before Jira comment, worklog, or status transition.

---

## Step 1 — Task Analysis

First, analyze the Etiyawiki/Jira task.

Extract:

- task summary
- task type
- project name
- repository URL
- local repository path
- target branch
- target file / folder / change scope
- table
- column
- metric / KPI
- procedure / function / model / script
- ETL / ELT job name
- scheduler / orchestration tool
- SQL query
- error message
- log detail
- Excel / document reference
- database / schema / environment
- customer ticket reference included in Etiyawiki/Jira

Then identify:

- risks
- assumptions
- blockers
- missing information
- whether repo resolution is required
- whether DB/SQL investigation is required
- whether Jira action is required

Always explain the initial analysis in Turkish.

Sensitive values from Jira/Etiyawiki must be masked in the output. Do not repeat full customer identifiers, emails, phone numbers, account IDs, invoice numbers, credentials, tokens, private keys, SSH keys, or connection strings.

---

## Step 2 — Workflow Routing

Route based on the task type.

### Repository / Git / Development

Use repo workflow if the task requires:

- file creation
- file update
- code/config change
- dbt model change
- SQL script change
- Python script change
- procedure/script update
- branch/commit/push

Before repo action, confirm:

- project name
- repository URL
- local repository path
- target branch
- target file, folder, model, procedure, script, or change scope

If any information is missing:

- stop repo execution
- ask the user for the missing information
- do not assume default paths
- do not modify files

### Data Investigation

Use investigation workflow if the task includes:

- data mismatch
- missing data
- duplicate data
- NULL value
- unexpected value
- wrong calculation
- KPI / metric issue
- customer ticket investigation
- SQL / DB analysis
- DWH / ETL / ELT analysis
- source vs target comparison
- lineage investigation

### ETL Error Investigation

Use ETL error investigation workflow if the task includes:

- failed ETL
- failed ELT
- failed dbt model
- failed procedure
- failed SQL script
- failed Python script
- scheduler / cron / orchestration failure
- monitoring alert
- API / Mongo / downstream load issue
- row count mismatch
- source file not received
- schema change
- invalid identifier
- conversion error
- array size / memory error
- disk / permission / timeout issue

### Jira-only Action

Use Jira workflow if the task only requires:

- comment
- status transition
- worklog
- acceptance note
- closure note
- operational follow-up note

---

## Step 3 — User Approval Before Action

Before any action, summarize:

- detected task type
- planned workflow
- confirmed project/repo information, if relevant
- planned Jira action, if relevant
- planned DB validation, if relevant
- production usage risk, if relevant
- sensitive data exposure risk, if relevant
- missing information
- what will not be done automatically

Then ask:

```text
Bu işlemleri uygulamamı ister misin? (yes/no)
```

Do not perform any of these before explicit user approval:

- modify files
- run Git checkout
- commit
- push
- add Jira comment
- transition Jira status
- add worklog
- run `dbconnect`, `snow`, `psql`, or `mongosh`
- execute SQL
- use production DB connections
- rerun ETL
- update control tables
- execute DB write SQL
- kill jobs
- restart services
- change cron/scheduler settings

---

## Step 4A — Investigation Execution

For data investigation or ETL error investigation:

1. Use Etiyawiki/Jira task content and user-provided context.
2. Mask sensitive values in the output.
3. Explain the problem in Turkish.
4. Identify the problematic object or failed component:

   - table
   - field / column
   - metric / KPI
   - job
   - procedure
   - model
   - script
   - source file
   - API / Mongo object

5. Identify the likely layer:

   - source
   - file transfer
   - BSS
   - DCE
   - i2i
   - STG
   - DWH
   - SEM, only when applicable
   - OPR / Monitoring
   - API / Mongo / downstream
   - scheduler / orchestration
   - infrastructure
   - Unknown

6. If repository/local path is confirmed, inspect code for:

   - target table
   - problematic column
   - metric / KPI
   - model / procedure / script
   - failed job
   - error keyword
   - upstream/downstream dependencies

7. If repository/local path is missing and code inspection is needed:

   - ask the user for the local repository path
   - continue only with task-content-level analysis if the user does not provide it

8. Generate safe diagnostic SQL only.
9. Do not execute SQL unless the user explicitly asks and approves.
10. If query execution is approved, follow Local CLI Based Read-Only DB Access rules.
11. Clearly mark unverified causes as hypotheses.
12. Suggest next actions and responsible team.

After investigation, ask:

```text
Bu inceleme sonucunu Jira'ya log olarak eklememi ister misin? (yes/no)
```

Only add Jira comment if the user explicitly approves.

---

## Step 4B — Repository Execution

For repository or code changes:

1. Verify the confirmed local repository path.
2. Verify it is a Git repository.
3. Show current branch.
4. Confirm target branch.
5. Do not touch protected branches:

   - main
   - master
   - prod
   - production
   - preprod
   - release/*

6. Checkout target branch only after approval.
7. Apply only the approved file/code/config change.
8. Do not modify unrelated files.
9. Do not edit credential files, secret files, private keys, `.env`, local DB config, or local SSH config.
10. Show changed files.
11. Show concise diff summary.
12. Stop if unexpected files changed.
13. Stop if the diff appears to contain credentials, tokens, private keys, passwords, connection strings, or sensitive customer values.
14. Ask:

```text
Değişiklikleri commit ve push yapmamı ister misin? (yes/no)
```

If the user explicitly approves:

- run `git add` only for relevant changed files
- do not use `git add .` unless explicitly approved and justified
- commit with a message containing the Jira ID when a Jira ID exists
- push only to the confirmed target branch
- suggest Jira execution log summary

Do not add Jira execution log unless the user explicitly approves.

---

## Step 4C — Jira Action Execution

For Jira-only or follow-up actions:

1. Read current issue status.
2. Check available transitions before changing status.
3. Prepare the comment/status/worklog action.
4. Mask sensitive values in Jira comment drafts unless exact values are strictly required.
5. Ask for approval.
6. Execute only approved Jira actions.

Do not close the issue automatically.

If the issue is `Cancelled`, `Closed`, `Resolved`, or `Done`:

- stop
- ask whether exceptional action is required

---

## Step 5 — Review

After the approved workflow:

- verify what was actually done
- verify changed files, if repo work was done
- verify Jira comments/logs, if Jira action was done
- verify investigation result is evidence-based
- verify sensitive values are masked in outputs
- verify missing information and assumptions are clearly stated
- prevent false completion claims

Then decide whether the task is ready for:

- no further action
- manual follow-up
- In Acceptance
- Closed

Before moving to `In Acceptance` or `Closed`, ask:

```text
Bu task için kaç saat worklog girmemi istersin? Örn: 30m, 1h, 2h. Eğer log girmek istemiyorsan 'skip' yazabilirsin.
```

If the user provides a duration:

- add Jira worklog using that duration
- add a short Jira comment saying worklog was added, only if approved

If the user says `skip`:

- do not add worklog

Then ask:

```text
Task'ı In Acceptance veya Closed statüsüne çekmemi ister misin? Hangi statüye çekeyim?
```

Only transition if the user explicitly approves.

---

## Strict Safety Rules

Follow the Data Engineer skill rules and package workflow strictly.

This command must especially enforce:

- Always respond in Turkish.
- Keep output concise and structured.
- Do not include internal reasoning or debug logs.
- Do not expose sensitive values.
- Never assume a default repository path.
- Never assume dbt exists or does not exist before inspecting project context.
- Never assume SEM exists for every project.
- Never modify files without approval.
- Never run Git checkout without confirmed repo/path/branch and approval.
- Never commit or push without approval.
- Never use force push.
- Never touch protected branches.
- Never execute SQL automatically.
- Never use production DB connections without explicit approval.
- Never run DB write operations.
- Never rerun ETL automatically.
- Never update control tables automatically.
- Never kill jobs or restart services automatically.
- Never change cron/scheduler automatically.
- Never add Jira comments without approval.
- Never transition Jira status without approval.
- Never add worklog without explicit duration.
- Never close the issue automatically.
- Never claim completion unless execution was actually done and verified.

---

## Output Format

Use the most relevant output format based on the selected workflow.

For initial execution summary:

1. Görev Özeti
2. Görev Tipi
3. Seçilen Workflow
4. Teknik Bilgiler
5. Proje / Repo Durumu
6. Riskler
7. Eksik Bilgiler
8. Planlanan Aksiyon
9. Onay Sorusu

For investigation result, follow the Data Engineer investigation output format.

For ETL error result, follow the Data Engineer ETL error output format.

For repo execution result:

1. Repo Bilgisi
2. Branch Bilgisi
3. Yapılan Değişiklikler
4. Değişen Dosyalar
5. Diff Özeti
6. Risk / Uyarı
7. Commit & Push Onay Sorusu

For final review:

1. Yapılan İşlem
2. Doğrulama Sonucu
3. Eksik / Riskli Noktalar
4. Jira Log Durumu
5. Worklog Durumu
6. Sonraki Statü Önerisi