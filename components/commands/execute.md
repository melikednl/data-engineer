---
description: Execute full Data Engineer workflow for Etiyawiki Jira tasks
subtask: true
---
Execute an Etiyawiki Jira task using the Data Engineer multi-workflow package.

Use the etiyawiki MCP server to get issue {{args}}.

Use the Data Engineer skill rules and package workflow.

## Purpose

This command orchestrates the full workflow for Etiyawiki Jira tasks across Data Engineering, DWH OPS, Development, and Operations teams.

It supports:

- task analysis
- repository / Git / development work
- data investigation
- ETL error investigation
- SQL / DWH / ELT analysis
- monitoring / rerun / operational follow-up
- Jira comments, status updates, worklog, and final review

This command must minimize unnecessary user interaction, but it must always ask for explicit approval before risky or irreversible actions.

---

## High-Level Flow

1. Analyze the Etiyawiki task.
2. Classify the task type.
3. Extract technical details.
4. Decide the correct workflow:
   - investigation workflow
   - ETL error investigation workflow
   - repo workflow
   - Jira workflow
   - manual follow-up
5. Ask for user approval before actions.
6. Execute only the approved workflow.
7. Review the result.
8. Ask before Jira worklog or status transition.

---

## Step 1 — Task Analysis

First, analyze the Etiyawiki task.

You must extract:

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
- customer ticket reference included in Etiyawiki

Then identify:

- risks
- assumptions
- blockers
- missing information
- whether repo resolution is required
- whether DB/SQL investigation is required
- whether Jira action is required

Always explain the initial analysis in Turkish.

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
- closure note
- operational follow-up note

---

## Step 3 — User Approval Before Action

Before any action, summarize:

- detected task type
- planned workflow
- confirmed project/repo information, if relevant
- planned Jira action, if relevant
- risks
- missing information
- what will not be done automatically

Then ask:

"Bu işlemleri uygulamamı ister misin? (yes/no)"

Do not perform any of these before approval:

- modify files
- run Git checkout
- commit
- push
- add Jira comment
- transition Jira status
- add worklog
- rerun ETL
- update control tables
- execute DB write SQL

---

## Step 4A — Investigation Execution

For data investigation or ETL error investigation:

1. Use Etiyawiki task content and user-provided context.
2. Explain the problem in Turkish.
3. Identify the problematic object or failed component:
   - table
   - field / column
   - metric / KPI
   - job
   - procedure
   - model
   - script
   - source file
   - API / Mongo object
4. Identify the likely layer:
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
5. If repository/local path is confirmed, inspect code for:
   - target table
   - problematic column
   - metric / KPI
   - model / procedure / script
   - failed job
   - error keyword
   - upstream/downstream dependencies
6. If repository/local path is missing and code inspection is needed:
   - ask the user for the local repository path
   - continue only with task-content-level analysis if the user does not provide it
7. Generate safe diagnostic SQL only.
8. Clearly mark unverified causes as hypotheses.
9. Suggest next actions and responsible team.

After investigation, ask:

"Bu inceleme sonucunu Jira'ya log olarak eklememi ister misin? (yes/no)"

Only add Jira comment if the user says yes.

---

## Step 4B — Repository Execution

For repository or code changes:

1. Verify the confirmed local repository path.
2. Show current branch.
3. Confirm target branch.
4. Do not touch protected branches:
   - main
   - master
   - prod
   - production
   - preprod
   - release/*
5. Checkout target branch only after approval.
6. Apply only the approved file/code/config change.
7. Do not modify unrelated files.
8. Show changed files.
9. Show concise diff summary.
10. Stop if unexpected files changed.
11. Ask:

"Değişiklikleri commit ve push yapmamı ister misin? (yes/no)"

If user says yes:

- run `git add` only for relevant changed files
- do not use `git add .` unless explicitly approved and justified
- commit with a message containing the Jira ID
- push only to the confirmed target branch
- add Jira execution log only after approval

---

## Step 4C — Jira Action Execution

For Jira-only or follow-up actions:

1. Read current issue status.
2. Check available transitions before changing status.
3. Prepare the comment/status/worklog action.
4. Ask for approval.
5. Execute only approved Jira actions.

Do not close the issue automatically.

If the issue is Cancelled, Closed, Resolved, or Done:

- stop
- ask whether exceptional action is required

---

## Step 5 — Review

After the approved workflow:

- verify what was actually done
- verify changed files, if repo work was done
- verify Jira comments/logs, if Jira action was done
- verify investigation result is evidence-based
- verify missing information and assumptions are clearly stated
- prevent false completion claims

Then decide whether the task is ready for:

- no further action
- manual follow-up
- Test
- Resolved

Before moving to Test or Resolved, ask:

"Bu task için kaç saat worklog girmemi istersin? Örn: 30m, 1h, 2h. Eğer log girmek istemiyorsan 'skip' yazabilirsin."

If user provides a duration:

- add Jira worklog using that duration
- add a short Jira comment saying worklog was added

If user says `skip`:

- do not add worklog

Then ask:

"Task'ı Test veya Resolved statüsüne çekmemi ister misin? Hangi statüye çekeyim?"

Only transition if user explicitly approves.

---

## Strict Safety Rules

- Follow the Data Engineer skill rules and package workflow strictly.
- Always respond in Turkish.
- Keep output concise and structured.
- Do not include internal reasoning or debug logs.
- Never assume a default repository path.
- Never assume dbt exists or does not exist before inspecting project context.
- Never assume SEM exists for every project.
- Never modify files without approval.
- Never run Git checkout without confirmed repo/path/branch and approval.
- Never commit or push without approval.
- Never use force push.
- Never touch protected branches.
- Never execute SQL automatically.
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