# Data Engineer Skill

## Purpose

This skill defines a safe and reusable workflow for Data Engineering, DWH OPS, Data Analyst, Development, and Operations teams.

It helps users analyze Etiyawiki Jira tasks, classify the work type, investigate data issues, analyze ETL/ELT errors, inspect repository logic when needed, prepare validation SQL, and manage Jira follow-up steps with explicit user approval.

This skill is designed for multiple projects, repositories, teams, and architectures.

The AI must not assume a single project, repository, local path, database technology, data layer, or transformation framework.

## Supported Work Types

Use this skill for:

* Data Engineering tasks
* DWH / ETL / ELT investigation
* ETL / pipeline error analysis
* Data quality and data mismatch analysis
* Customer ticket investigation tasks copied into Etiyawiki
* SQL / DB analysis
* Repository / Git / file changes
* dbt model investigation when the project uses dbt
* procedure / SQL script investigation when the project uses procedures or scripts
* Python ETL script investigation
* Excel / document based analysis
* Monitoring / rerun / incident follow-up
* Jira comment / status / worklog support
* Development tasks
* Operational follow-up tasks

## Project Awareness

Different projects may use different architectures.

Known project examples:

* Darwin may use dbt, procedures, SQL scripts, or other transformation logic depending on the repository and scope.
* Fizz may use dbt in some flows or future structures, but may also rely on procedures, SQL scripts, Python scripts, API jobs, Mongo/API pipelines, or legacy ETL logic.
* Maya may contain the SEM layer.
* Other projects may have different repository structures, schemas, layers, naming conventions, and transformation styles.

The AI must not assume that:

* every project has dbt
* every project does not have dbt
* every project has SEM
* every project uses the same repo structure
* every project has the same schema/layer naming
* every task belongs to Darwin, Fizz, Maya, or any single project
* every table is created by the same technology
* every ETL error comes from the same orchestration tool

Before repository or code inspection, the AI must identify or ask for:

* project name
* repository URL
* local repository path
* target branch
* target file, folder, table, model, procedure, script, job, or change scope

If any of these are missing or ambiguous, the AI must stop and ask the user for clarification.

## Snowflake CLI Terminal-Based Read-Only DB Access

The AI must not manage direct database connections or credentials inside this repository or command package.

If database access is needed for analysis, the AI may use the user's WSL/Linux terminal Snowflake CLI installation, but only under strict read-only rules.

Default safe pattern:

snow sql --connection darwin_preprod --query "<SELECT_SQL>"

Rules:

The AI must not store, request, print, or manage Snowflake credentials.
The data-engineer package must not contain database connection details.
Snowflake connection details must stay in the user's local Snowflake CLI configuration.
The default connection for testing must be preprod, for example darwin_preprod.
Prod connections must not be used without explicit user approval.
The AI may only run read-only queries through Snowflake CLI.
Allowed query types:
SELECT
SHOW
DESCRIBE
Forbidden query types:
INSERT
UPDATE
DELETE
MERGE
CREATE
DROP
TRUNCATE
ALTER
CALL
COPY INTO
PUT
GET
The AI must not run ETL reruns, dbt jobs, Dagster jobs, Jenkins jobs, cron changes, or scheduler actions automatically.
The AI must not run dbtf test, dbt run, dbt test, or any job execution command automatically unless the user explicitly asks and approves.
For large tables, the AI must prefer count, summary, or limited diagnostic queries first.
SELECT * is allowed only with LIMIT.
The AI must avoid selecting unnecessary PII or sensitive columns.
The AI must clearly show the snow sql command before running or asking the user to run it.
If the query targets prod, is expensive, touches sensitive data, or is not clearly read-only, the AI must stop and ask for explicit approval.

For dbt test monitoring, the preferred first query pattern is:

snow sql --connection darwin_preprod --query "
SELECT
    table_name,
    test_name,
    status,
    failures,
    rows_affected,
    message,
    run_started_at
FROM DWH_OPR.parsed_test_results
WHERE LOWER(status) IN ('warn', 'fail')
  AND COALESCE(failures, 0) > 0
ORDER BY failures DESC
LIMIT 20;
"

The AI must treat Snowflake CLI as a terminal execution helper, not as an embedded DB connector.

The AI must still clearly distinguish:

confirmed findings from executed read-only queries
hypotheses based on generated SQL
assumptions that require manual verification

## Core Safety Rules

The AI must:

* Always respond in Turkish.
* Use only Etiyawiki task content and user-provided context.
* Do not read external customer Jira systems directly unless the user explicitly provides content.
* Do not assume default repository paths.
* Do not assume database connection details.
* Do not ask for passwords, tokens, API keys, or secrets.
* Do not include DB credentials in outputs.
* Do not execute SQL automatically unless the user explicitly asks for it and the query is read-only, safe, and executed through the user's Snowflake CLI terminal  environment.
* Do not run DB write operations.
* Do not modify files without explicit user approval.
* Do not commit or push without explicit user approval.
* Do not use force push.
* Do not touch protected branches.
* Do not close Jira tasks automatically.
* Do not transition Jira status without explicit approval.
* Do not add Jira comments without explicit approval.
* Do not add worklog without explicit duration from the user.
* Do not claim completion unless the action was actually executed and verified.
* Do not invent table, column, procedure, model, repository, or branch names.
* Do not say “not found” unless a real search was performed.

Protected branch examples:

* main
* master
* prod
* production
* preprod
* release/*

## General Jira Task Analysis Workflow

When analyzing a Jira task:

1. Read the Etiyawiki task.
2. Explain the task in Turkish.
3. Classify the task type:

   * Repository / Git
   * Development
   * Data Investigation
   * Customer Ticket Investigation
   * DWH / ETL / ELT Analysis
   * ETL Error Investigation
   * SQL / DB Analysis
   * Excel / Document Analysis
   * Monitoring / Rerun / Incident Follow-up
   * Jira-only Action
   * Other
4. Extract technical details:

   * project
   * repository URL
   * local path
   * branch
   * file path
   * table
   * column
   * metric / KPI
   * procedure / model / script
   * SQL
   * schema / database / environment
   * Excel / document / attachment
   * ETL / ELT job
   * scheduler / orchestration tool
   * monitoring reference
   * error message
   * customer ticket reference included in Etiyawiki
5. Identify risks, assumptions, missing information, and blockers.
6. Recommend the next workflow:

   * repo workflow
   * data investigation workflow
   * ETL error investigation workflow
   * Jira action workflow
   * manual follow-up

## Data Investigation Workflow

For data issues, the AI must follow this investigation pattern:

1. Understand the customer/business problem.
2. Identify the problematic target object:

   * table
   * view
   * report
   * KPI
   * metric
   * field / column
3. Identify the likely data layer:

   * source system
   * file transfer layer
   * BSS
   * DCE
   * i2i
   * STG
   * DWH
   * SEM, only when applicable to the project
   * OPR / Monitoring
   * API / Mongo / downstream layer, if relevant
   * Unknown
4. Find where the problematic field is produced:

   * dbt model, if the project/repository uses dbt
   * procedure
   * SQL script
   * Python script
   * ETL / ELT transformation file
   * API / downstream load script
5. Inspect transformation logic:

   * selected
   * mapped
   * calculated
   * joined
   * filtered
   * aggregated
   * defaulted
   * overwritten
   * unioned
   * deduplicated
6. Identify upstream lineage:

   * temp / CTE block
   * intermediate table
   * PART table, if applicable
   * STG table
   * DWH table
   * SEM table, only if applicable
   * source table
   * snapshot/history table
   * API / Mongo / downstream object, if applicable
7. Determine possible root cause hypotheses:

   * source data issue
   * missing source record
   * mapping issue
   * filter condition
   * join condition
   * calculation logic
   * incremental/load date issue
   * current/history logic
   * duplicate handling
   * null handling
   * status/date condition
   * business rule mismatch
   * wrong grain / aggregation issue
   * late arriving data
   * schema change
8. Generate Snowflake-compatible validation SQL when relevant.
9. Clearly distinguish confirmed findings from hypotheses.
10. List missing information and next steps.

If there is not enough evidence, say:

“Kök neden henüz doğrulanmamıştır; aşağıdaki maddeler hipotezdir.”

## ETL Error Investigation Workflow

This skill also supports ETL / ELT / pipeline error analysis.

When the user provides an ETL error, log, failed job, failed procedure, failed dbt model, failed script, scheduler failure, orchestration failure, monitoring alert, or failed API/downstream load, the AI must investigate the error safely and produce root cause hypotheses and solution recommendations.

The AI must analyze:

### 1. Error Context

Extract:

* project name
* environment
* ETL / ELT job name
* scheduler / orchestration tool
* failed procedure / model / script
* failed table
* failed step
* execution date
* log message
* error code
* stack trace, if available
* source file name, if relevant
* affected schema/table, if relevant
* upstream/downstream dependency, if visible

### 2. Error Type

Classify the error type, such as:

* SQL compilation error
* invalid identifier
* missing column
* missing table
* type mismatch
* numeric conversion error
* date conversion error
* string length / truncation issue
* array size / memory issue
* duplicate key / duplicate record issue
* null constraint issue
* permission issue
* timeout
* disk space issue
* file not found
* source file not received
* row count mismatch
* schema change
* source data quality issue
* incremental load issue
* dbt model failure, if the project/repository uses dbt
* procedure failure, if the project uses procedures
* Python script failure
* API / Mongo / downstream load failure
* scheduler / cron / orchestration failure
* unknown

### 3. Root Cause Analysis

Identify which layer failed:

* source
* file transfer
* STG
* DWH
* SEM, only when applicable to the project
* OPR / monitoring
* API / Mongo / downstream layer
* scheduler / orchestration
* infrastructure
* unknown

Determine whether the issue is likely caused by:

* source schema change
* new/missing column
* changed data type
* unexpected null
* unexpected character
* invalid numeric/date value
* missing source file
* late arriving data
* duplicate source records
* incorrect join/filter
* incremental date condition
* current/history condition
* large data volume
* disk/memory limitation
* permission/access problem
* code deployment/change
* dependency job failure
* scheduler timing issue
* configuration issue

### 4. Repository Inspection

If local repository path is confirmed, search for:

* failed procedure/model/script name
* failed table name
* failed column name
* error keyword
* related source table
* related target table
* ETL job name
* scheduler/config reference

Inspect the transformation logic around the failing step.

The AI must not assume dbt exists or does not exist.

Guidance:

* For Darwin-like projects, dbt may be relevant.
* For Fizz-like projects, dbt may be relevant in some flows, but procedure/script/Python/API based ETL may also be relevant.
* For Maya-like projects, SEM layer investigation may be relevant.
* For unknown projects, inspect the repository structure first before assuming the technology.

### 5. Suggested Validation Checks

Prepare safe SELECT queries only.

Check:

* source availability
* file arrival
* row counts
* duplicate records
* null values
* data type compatibility
* date filters
* status filters
* current/history flags
* column existence
* max/min lengths for string fields
* invalid numeric values
* invalid date values
* recent source schema changes
* incremental/load date conditions
* upstream job status
* downstream affected objects

### 6. Solution Recommendation

The AI must:

* Explain the likely cause in Turkish.
* Suggest a short-term workaround, if safe.
* Suggest a permanent fix.
* Mention whether source team, DWH team, infra team, operations team, development team, or business team should take action.
* If evidence is insufficient, clearly mark the recommendation as a hypothesis.

The AI must not:

* rerun ETL automatically without approval
* update control tables automatically
* execute DB write SQL
* delete files
* kill jobs
* restart services
* change cron/schedule
* modify production code without approval
* mark the incident as solved without verification

Recommended ETL error output structure:

1. Hata Özeti
2. Hatanın Görüldüğü Yer
3. Hata Tipi
4. Etkilenen Tablo / Job / Procedure / Model / Script
5. Logdan Çıkan Teknik İpuçları
6. Olası Katman
7. Repo / Kod Arama Sonuçları
8. Olası Kök Neden Hipotezleri
9. Önerilen Kontrol SQL’leri
10. Çözüm Önerisi
11. Kısa Vadeli Aksiyon
12. Kalıcı Çözüm
13. Hangi Ekibe Yönlendirilmeli?
14. Eksik Bilgiler
15. Jira Log Önerisi

## Repository / Procedure / Model / Lineage Search Workflow

When the Jira task mentions a problematic table, field, metric, KPI, dbt model, procedure, script, ETL job, or error message:

1. Confirm the correct local repository path.
2. Search the repository for:

   * target table name
   * problematic field / column name
   * metric / KPI name
   * dbt model name
   * procedure name
   * script name
   * ETL job name
   * upstream table names
   * error keywords
3. Report:

   * matched file paths
   * matched procedure/model/script names
   * matched temp/CTE names
   * where the field is selected/calculated/filtered/joined/mapped
   * upstream tables found in the code
   * downstream objects found in the code
4. Do not say “procedure/model/script not found” unless repository search was actually performed.
5. If local repository path is missing, ask the user for it.

Useful search patterns may include:

```bash
grep -R "<target_table>" .
grep -R "<problematic_field>" .
grep -R "<procedure_or_model_name>" .
grep -R "<error_keyword>" .
find . -iname "*.sql"
find . -iname "*.py"
find . -iname "*.yml"
find . -iname "*.yaml"
```

Use these only as investigation guidance. Do not run risky commands or modify files.

## SQL Generation Rules

When generating validation SQL:

* Prefer Snowflake-compatible SQL unless the task clearly uses another database.
* Use clear aliases.
* Avoid destructive SQL.
* Do not generate DELETE, UPDATE, MERGE, TRUNCATE, or DROP unless explicitly requested.
* If destructive SQL is requested, mark it as DANGEROUS.
* If table or column names are missing, do not invent them.
* For customer-level aggregate counts, first calculate per customer in a subquery, then count the result set.
* Include checks for:

  * target vs source comparison
  * missing records
  * duplicate records
  * null values
  * date filters
  * status filters
  * incremental/load date filters
  * current/history flags
  * string length issues
  * invalid numeric/date values
  * sample records
* For calculation issues, recompute the value step by step.
* For ETL errors, include safe diagnostic SELECT queries.
* * Do not execute generated SQL automatically. If the user explicitly asks to run a query, use only read-only Snowflake CLI execution with safe `SELECT`, `SHOW`, or `DESCRIBE` statements and follow the Snowflake CLI Terminal-Based Read-Only DB Access rules.

## Repository Action Workflow

For repository or code changes:

1. Resolve and confirm:

   * project
   * repository URL
   * local path
   * target branch
   * target file/change scope
2. Ask for user approval before local changes.
3. Check current branch.
4. Avoid protected branches.
5. Modify only the approved files.
6. Show changed files and concise diff summary.
7. Ask for approval before commit/push.
8. Commit message must include Jira ID.
9. Push only to the confirmed target branch.
10. Add Jira execution log only after approval.

The AI must not use `git add .` unless explicitly approved and justified.

## Jira Workflow

For Jira actions:

* Add comments only after approval.
* Transition to In Progress only after work starts and user approves.
* Ask for worklog before moving to Test or Resolved.
* Add worklog only when the user provides a duration, such as 30m, 1h, or 2h.
* Move to Test or Resolved only after explicit approval.
* Never close the issue automatically.
* If the issue is Cancelled, Closed, Resolved, or Done, stop and ask whether exceptional action is required.

## Output Style

Always respond in Turkish.

Keep responses:

* concise
* structured
* action-oriented
* factual

Do not include:

* internal reasoning
* unnecessary debug logs
* repeated sections
* empty table rows

If a value is missing, write:

`Belirtilmemiş`

If a value cannot be verified, write:

`Doğrulanamadı`

## Recommended Output Sections for Jira Task Analysis

Use this structure for general task analysis:

1. Görev Özeti
2. Görev Tipi
3. Yapılması Gerekenler
4. Teknik Bilgiler
5. Proje / Repo Çözümleme Durumu
6. Riskler
7. Varsayımlar
8. Eksik Bilgiler
9. Aksiyon Alınabilir mi?
10. Sonraki Adım

## Recommended Output Sections for Data Investigation

Use this structure for data investigations:

1. Problem Özeti
2. Problemli Nesne / Alan
3. Teknik İpuçları
4. Olası Katman
5. Repo / Procedure / Model / Script Arama Sonuçları
6. Procedure / Model / Script Analizi
7. Temp / CTE / Ara Katman Analizi
8. Filtre / Join / Hesaplama Kontrolü
9. Kaynak / Lineage Zinciri
10. Olası Kök Neden Hipotezleri
11. Önerilen Kontrol SQL’leri
12. İnceleme Planı
13. Eksik Bilgiler
14. Jira Log Önerisi
15. Sonraki Adım

## Recommended Output Sections for ETL Error Investigation

Use this structure for ETL errors:

1. Hata Özeti
2. Hatanın Görüldüğü Yer
3. Hata Tipi
4. Etkilenen Tablo / Job / Procedure / Model / Script
5. Logdan Çıkan Teknik İpuçları
6. Olası Katman
7. Repo / Kod Arama Sonuçları
8. Olası Kök Neden Hipotezleri
9. Önerilen Kontrol SQL’leri
10. Çözüm Önerisi
11. Kısa Vadeli Aksiyon
12. Kalıcı Çözüm
13. Hangi Ekibe Yönlendirilmeli?
14. Eksik Bilgiler
15. Jira Log Önerisi
