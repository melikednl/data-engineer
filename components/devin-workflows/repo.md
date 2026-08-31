---
name: repo
description: Resolve repository context and safely apply approved code changes
---

Resolve repository context and apply safe repository changes for Etiyawiki/Jira tasks.

Use the configured Etiyawiki/Jira MCP server to get issue `{{args}}`.

Follow the Data Engineer skill rules, especially:

- Project Awareness
- Repository Action Workflow
- Sensitive Data Handling
- Jira / Rovo MCP Data Safety
- Core Safety Rules
- Jira Workflow

## Purpose

This command handles repository-related work for Data Engineering, DWH OPS, Development, and Operations teams.

It supports:

- project / repository resolution
- local path validation
- branch validation
- file / code / config change planning
- dbt model changes when applicable
- SQL script or procedure changes when applicable
- Python script changes when applicable
- scheduler / orchestration config changes when applicable
- API / Mongo / downstream script changes when applicable
- safe Git diff preparation
- commit and push only after explicit user approval

This command must prevent the AI from using the wrong repository, wrong branch, wrong local path, or wrong file.

This command may inspect and modify repository files only after the required context is confirmed and the user explicitly approves the change.

It must not:

- assume a default repository path
- modify files without explicit user approval
- modify unrelated files
- run DB write operations
- run ETL reruns
- update control tables
- add Jira comments
- transition Jira status
- add worklog
- commit without explicit user approval
- push without explicit user approval
- force push
- touch protected branches

---

## Phase 1 — Repository Resolution

Read the Etiyawiki/Jira task and extract:

- Jira ID
- project name
- repository URL
- local repository path
- target branch
- target file / folder / model / procedure / script / change scope
- expected action
- related environment


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

Sensitive values from Jira/Etiyawiki task content must be masked in the output.

---

## Phase 2 — Technology Awareness

Before modifying files, inspect or infer from confirmed repository context whether the project uses:

- dbt models
- SQL scripts
- stored procedures
- Python ETL scripts
- scheduler / orchestration configs
- API / Mongo / downstream load scripts
- other project-specific structures

Do not assume:

- every project uses dbt
- every project does not use dbt
- every project has SEM
- every project uses the same folder structure

Guidance:

- Darwin-like projects may use dbt, procedures, SQL scripts, Python scripts, or other transformation logic.
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
- target files / change scope
- planned change
- risk level
- protected branch check
- sensitive data / credential exposure risk, if relevant

Then ask:

```text
Bu repo değişikliğini uygulamamı ister misin? (yes/no)
```

Do not modify files unless the user explicitly approves.

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
10. Do not edit credential files, secret files, private keys, `.env`, local DB config, or local SSH config.
11. Show changed files.
12. Show concise diff summary.
13. Stop if unexpected files changed.
14. Stop if the diff appears to contain credentials, tokens, private keys, passwords, connection strings, or sensitive customer values.

---

## Phase 5 — Commit and Push Approval

After showing the diff summary, ask:

```text
Değişiklikleri commit ve push yapmamı ister misin? (yes/no)
```

If the user explicitly approves:

- run `git add` only for relevant changed files
- do not use `git add .` unless explicitly approved and justified
- commit with a message containing the Jira ID when a Jira ID exists
- push only to the confirmed target branch
- report commit hash if available
- suggest Jira execution log summary

Do not commit or push if the user does not explicitly approve.

---

## Safety Rules

Follow the centralized Data Engineer skill safety rules.

This command must especially enforce:

- no default repository path assumptions
- no Git commands when repo/path/branch/change scope is missing
- no checkout without confirmed repo/path/branch and approval
- no file modification without explicit approval
- no unrelated file modification
- no credential, token, private key, SSH key, `.env`, local DB config, or connection string changes
- no sensitive data exposure in output
- no commit without explicit approval
- no push without explicit approval
- no force push
- no protected branch changes
- no DB write operations
- no control table update
- no ETL rerun
- no Jira comments or Jira status transitions from this command

If the task is `Cancelled`, `Closed`, `Resolved`, or `Done`, stop and ask whether exceptional action is required.

If the target file or branch does not exist, stop and explain.

---

## Output Format

Before execution:

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
