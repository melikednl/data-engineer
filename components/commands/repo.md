---
description: Resolve repository context and safely apply approved code changes
---
Resolve repository context and apply safe repository changes for Etiyawiki Jira tasks.

Use the etiyawiki MCP server to get issue {{args}}.

Use the Data Engineer skill rules and package workflow.

## Purpose

This command handles repository-related work for Data Engineering, DWH OPS, Development, and Operations teams.

It supports:

- project / repository resolution
- local path validation
- branch validation
- file/code/config change planning
- dbt model changes when applicable
- SQL script or procedure changes when applicable
- Python script changes when applicable
- safe Git diff preparation
- commit and push only after explicit user approval

This command must prevent the AI from using the wrong repository, wrong branch, wrong local path, or wrong file.

---

## Phase 1 — Repository Resolution

Read the Etiyawiki task and extract:

- project name
- repository URL
- local repository path
- target branch
- target file / folder / model / procedure / script / change scope
- expected action
- related environment
- Jira ID

Repository execution is allowed only if all of these are confirmed:

- project name
- repository URL
- local repository path
- target branch
- target file, folder, model, procedure, script, or change scope

If any item is missing, ambiguous, inconsistent, or not verifiable:

- do not run Git commands
- do not checkout branch
- do not modify files
- do not commit
- do not push
- ask the user for the missing information

Never assume a default local repository path.

---

## Phase 2 — Technology Awareness

Before modifying files, inspect or infer from confirmed repository context whether the project uses:

- dbt models
- SQL scripts
- stored procedures
- Python ETL scripts
- scheduler/orchestration configs
- API / Mongo / downstream load scripts
- other project-specific structures

Do not assume:

- every project uses dbt
- every project does not use dbt
- every project has SEM
- every project uses the same folder structure

Guidance:

- Darwin-like projects may use dbt, procedures, SQL scripts, or other transformation logic.
- Fizz-like projects may use dbt in some flows, but procedure/script/Python/API based ETL may also be relevant.
- Maya-like projects may include SEM layer investigation.
- Unknown projects must be inspected before assuming the technology.

---

## Phase 3 — Approval Before Local Changes

Before modifying anything, summarize:

- confirmed project
- confirmed repository URL
- confirmed local path
- current branch
- target branch
- target files/change scope
- planned change
- risk level
- protected branch check

Then ask:

"Bu repo değişikliğini uygulamamı ister misin? (yes/no)"

Do not modify files unless the user says yes.

---

## Phase 4 — Safe Repo Execution

If the user approves:

1. Go to the confirmed local repository path.
2. Verify it is a Git repository.
3. Show current branch.
4. Confirm target branch.
5. Fetch target branch if needed.
6. Checkout target branch only after approval.
7. Stop if target branch is protected:
   - main
   - master
   - prod
   - production
   - preprod
   - release/*
8. Apply only the approved local change.
9. Do not modify unrelated files.
10. Show changed files.
11. Show concise diff summary.
12. Stop if unexpected files changed.

---

## Phase 5 — Commit and Push Approval

After showing the diff summary, ask:

"Değişiklikleri commit ve push yapmamı ister misin? (yes/no)"

If user says yes:

- run `git add` only for relevant changed files
- do not use `git add .` unless explicitly approved and justified
- commit with a message containing the Jira ID
- push only to the confirmed target branch
- report commit hash if available
- suggest Jira execution log summary

Do not commit or push if the user does not explicitly approve.

---

## Safety Rules

- Always respond in Turkish.
- Use only Etiyawiki task content and user-provided context.
- Never assume a default repository path.
- Never run Git commands if repo/path/branch/change scope is missing.
- Never checkout branch without confirmed repo/path/branch and approval.
- Never modify files without approval.
- Never modify unrelated files.
- Never commit without approval.
- Never push without approval.
- Never force push.
- Never touch protected branches:
  - main
  - master
  - prod
  - production
  - preprod
  - release/*
- Never run DB write operations.
- Never update control tables automatically.
- Never rerun ETL automatically.
- If the task is Cancelled, Closed, Resolved, or Done, stop and ask whether exceptional action is required.
- If the target file/branch does not exist, stop and explain.

---

## Output Format

1. Repo İş Özeti
2. Proje Bilgisi
3. Repository Bilgisi
4. Local Path Bilgisi
5. Branch Bilgisi
6. Değişiklik Kapsamı
7. Teknoloji / Proje Yapısı
8. Eksik veya Belirsiz Bilgiler
9. Riskler
10. Aksiyon Alınabilir mi?
11. Onay Sorusu

After execution:

1. Repo Bilgisi
2. Branch Bilgisi
3. Yapılan Değişiklikler
4. Değişen Dosyalar
5. Diff Özeti
6. Risk / Uyarı
7. Commit & Push Onay Sorusu