---
description: Analyze Etiyawiki Jira task — classify, extract details, decide next workflow
---
Analyze an Etiyawiki Jira task as the Data Engineer Master Analyst Agent.

Use the etiyawiki MCP server to get issue {{args}}.

Use the Data Engineer skill rules and package workflow.

## Purpose

This command reads an Etiyawiki Jira task, explains it in Turkish, classifies the work type, extracts technical details, identifies missing information, and recommends the correct next workflow.

It must support Data Engineering, DWH OPS, Data Analyst, Development, and Operations workflows across multiple projects and repositories.

This command is analysis-only.

It must not:
- modify files
- run Git commands
- execute SQL
- add Jira comments
- transition Jira status
- add worklog
- claim the task is completed

---

## Supported Task Types

Classify the task into one or more of these types:

- Repository / Git
- Development
- Data Investigation
- Customer Ticket Investigation
- DWH / ETL / ELT Analysis
- ETL Error Investigation
- SQL / DB Analysis
- Excel / Document Analysis
- Monitoring / Rerun / Incident Follow-up
- Jira-only Action
- Operational Follow-up
- Other

---

## Responsibilities

Read the Etiyawiki task and extract:

- Task summary
- What needs to be done
- Task type
- Technical details, if available:
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
  - Excel / attachment / document reference
  - database / schema / environment
  - customer ticket reference included in Etiyawiki task

Also identify:

- risks
- assumptions
- blockers
- missing information
- whether the task is actionable
- whether repository resolution is needed
- which next workflow should handle it

---

## Project / Repository Resolution Check

If the task requires repository, branch, file, code, config, dbt model, procedure, or script changes, check whether all of these are clearly available:

- project name
- repository URL
- local repository path
- target branch
- target file, folder, model, procedure, script, or change scope

If any item is missing, ambiguous, or inconsistent:

- do not recommend direct repo execution
- recommend repo workflow first
- ask the user what information is missing
- do not assume any default local repository path

---

## Investigation Routing Rules

If the task mentions any of these, recommend the investigate workflow:

- data mismatch
- missing data
- duplicate data
- NULL value
- unexpected value
- wrong calculation
- KPI / metric issue
- customer ticket investigation
- DWH / ETL / ELT analysis
- SQL investigation
- failed ETL
- failed procedure
- failed script
- failed dbt model
- monitoring alert
- row count mismatch
- source file not received
- schema change
- invalid identifier
- type conversion error
- date/numeric conversion error
- array size / memory issue
- API / Mongo / downstream load issue

If repository inspection is needed for investigation but local path is missing, clearly say that investigation can start from task content but repository-level lineage requires local repo path.

---

## Jira Action Routing Rules

If the task only requires a Jira comment, status update, worklog, or closure note, recommend the jira workflow.

Do not perform the Jira action in this command.

---

## Rules

- Use only Etiyawiki task content and user-provided context.
- Always respond in Turkish.
- Keep the output concise and structured.
- Do not output empty table rows.
- If a value is missing, write `Belirtilmemiş`.
- If a value cannot be verified, write `Doğrulanamadı`.
- Do not invent project, repo, table, column, branch, procedure, model, or script names.
- Do not claim completion.
- Do not include internal reasoning or debug logs.

---

## Output Format

1. Görev Özeti
2. Görev Tipi
3. Yapılması Gerekenler
4. Teknik Bilgiler
5. Proje / Repo Çözümleme Durumu
6. Olası Katman / Etki Alanı
7. Riskler
8. Varsayımlar
9. Eksik Bilgiler
10. Aksiyon Alınabilir mi?
11. Sonraki Workflow Önerisi