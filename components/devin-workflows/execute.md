Execute an Etiyawiki Jira task using the professional multi-agent workflow.

Use the etiyawiki MCP server to get issue $ARGUMENTS[0].

Use the workflow rules from:
~/codes/eltstack/AGENTS_AI.md

## Goal

Run the full workflow with minimum user intervention, but with explicit approval before risky actions.

This command supports:
- development tasks
- repository / Git / file changes
- data investigation tasks
- DWH / ETL / SQL analysis
- operational follow-up tasks
- Jira-only actions

---

## Agent Flow

### 1. Master Analyst Agent

First analyze the Etiyawiki task.

You must:
- Explain the task briefly in Turkish.
- Determine the task type.
- Extract technical details when available:
  - project name
  - repository URL
  - local repository path
  - target branch
  - target file / folder / change scope
  - table
  - column
  - procedure / function
  - SQL
  - Excel / document reference
  - database / schema / environment
- Identify risks, assumptions, blockers, and missing information.
- Decide the next workflow:
  - Repository / Git / Development → Project Resolver + Repo Execution workflow
  - Data Investigation / DWH / SQL / Customer Ticket Investigation → Data Investigation workflow
  - Operational Follow-up / Jira-only Action → Jira Action workflow
  - Terminal / Cancelled task → stop and ask for exceptional approval

---

### 2. Project Resolver Agent

If the task requires repository, branch, file, code, or config changes, resolve and confirm:

- project name
- repository URL
- local repository path
- target branch
- target file, folder, or change scope

Rules:
- Never assume a default local repository path.
- Use a local project registry if available.
- If local repository path is missing or uncertain, ask the user.
- If target branch is missing or uncertain, ask the user.
- If target file or change scope is missing or uncertain, ask the user.
- If multiple repositories, branches, or local paths are possible, ask the user to confirm.
- Do not continue to repo execution until project, repo, local path, branch, and change scope are confirmed.

If information is missing, ask:

"Bu task için repo aksiyonuna geçmeden önce eksik bilgileri netleştirmem gerekiyor. Lütfen proje adı, repo URL, local repo path, target branch ve değişiklik kapsamını paylaşır mısın?"

---

### 3. User Approval Before Execution

After analysis and project/repo resolution, summarize:

- task type
- confirmed project/repo information
- planned action
- risks
- next workflow

Then ask:

"Bu işlemleri uygulamamı ister misin? (yes/no)"

Do not modify files, add Jira comments, transition status, commit, or push before this approval.

---

### 4. Jira Action Agent — Start Work

Only if the user says yes:

- Add a Jira comment:
  "Çalışma başlatıldı. İlk analiz tamamlandı ve uygun agent akışına geçiliyor."

- Transition the issue to "In Progress" if:
  - it is not already there
  - the transition is available
  - the user has permission

If Jira action fails due to assignment or permission, explain the issue and continue only if the user approves the remaining local actions.

---

### 5A. Repo Execution Agent

Use this path only if the task is Repository / Git / Development and repo resolution is complete.

Actions:
- Go to the confirmed local repository path.
- Do not use any fallback local path.
- Verify the local repo exists.
- Show current branch.
- Fetch target branch if needed.
- Checkout target branch only after approval.
- Never touch protected branches:
  - main
  - master
  - prod
  - production
  - preprod
  - release/*
- Apply only the required local change.
- Do not modify unrelated files.
- Show changed files and concise diff summary.
- Stop if more files changed than expected.

Then ask:

"Değişiklikleri commit ve push yapmamı ister misin? (yes/no)"

If user says yes:
- Run `git add` only for relevant changed files.
- Do not use `git add .` unless explicitly approved and justified.
- Commit with a message containing the Jira ID.
- Push only to the confirmed target branch.
- Add a Jira execution log comment summarizing:
  - changed files
  - commit message
  - push target branch
  - approvals received

---

### 5B. Data Investigation Agent

Use this path if the task is Data Investigation, DWH/ETL Analysis, SQL/DB Analysis, Excel/Document Analysis, Customer Ticket Investigation, Monitoring/Rerun issue, or operational data problem.

Actions:
- Analyze the issue using only Etiyawiki task content and provided context.
- Explain the customer/data problem in Turkish.
- Identify the problematic target object:
  - table
  - view
  - report
  - KPI
  - metric
  - column / field
- Identify the likely data layer:
  - BSS
  - DCE
  - i2i
  - STG
  - DWH
  - OPR / Monitoring
  - Unknown
- Extract relevant technical clues:
  - tables
  - columns
  - procedures / functions
  - SQL
  - Excel / document references
  - schemas
  - environments
  - logs
  - ETL / ELT job references
- If repository information and local path are confirmed, inspect local procedure/model/script files to understand:
  - where the problematic field is selected
  - where it is calculated
  - where it is filtered
  - where it is joined
  - where it is mapped
  - which upstream tables feed it
- If repository/local path is not confirmed, do not assume a repo path. Ask the user for the relevant repo/local path if procedure/model inspection is needed.
- Identify whether the issue may be caused by:
  - filter condition
  - join condition
  - calculation logic
  - source mapping issue
  - source data issue
  - incremental/load date filter
  - current/history logic
  - duplicate/null handling
  - status/date condition
- Generate Snowflake-compatible validation SQL for each relevant layer.
- Clearly list missing information.
- Mark root cause as hypothesis unless evidence exists.
- Do not connect to the database directly.
- Do not run DB write operations.

Then ask:

"Bu inceleme sonucunu Jira'ya log olarak eklememi ister misin? (yes/no)"

If user says yes:
- Add a concise Jira investigation log comment including:
  - problem summary
  - suspected layer
  - key hypotheses
  - suggested validation SQL summary
  - missing information

---

### 5C. Jira Action Agent — Operational Follow-up

Use this path if the task only requires Jira-side action.

Actions may include:
- add comment
- transition status
- add worklog
- prepare closure note

Always ask for explicit approval before action.

---

### 6. Review Agent

After repository action, data investigation, or Jira action:

- Verify whether the requested action was actually performed.
- Verify Jira comments/logs.
- Verify repo branch/file changes when relevant.
- Prevent false completion claims.
- Decide whether the issue is ready for:
  - no action
  - manual follow-up
  - Test
  - Resolved

Before transitioning to Test or Resolved, ask:

"Bu task için kaç saat worklog girmemi istersin? Örn: 30m, 1h, 2h. Eğer log girmek istemiyorsan 'skip' yazabilirsin."

If user provides a duration:
- Add Jira worklog using that duration.
- Add a short Jira comment saying worklog was added.

If user says skip:
- Do not add worklog.

Then ask:

"Task'ı Test veya Resolved statüsüne çekmemi ister misin? Hangi statüye çekeyim?"

Only transition if user explicitly approves.

---

## Strict Safety Rules

- Follow `AGENTS_AI.md` strictly.
- Always respond in Turkish.
- Keep output concise.
- Do not repeat analysis.
- Do not include internal reasoning or debug logs.
- Never assume a default repository path.
- Never modify files without approval.
- Never run Git checkout without confirmed repo/path/branch.
- Never commit or push without approval.
- Never run DB write operations.
- Never force push.
- Never touch protected branches.
- Never close the issue automatically.
- Never claim completion unless execution was actually done and verified.
