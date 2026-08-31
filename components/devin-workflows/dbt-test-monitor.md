---
name: dbt-test-monitor
description: Analyze dbt test/freshness results from DWH_OPR.parsed_test_results and generate safe validation SQL
---


Analyze dbt test and freshness results from `DWH_OPR.parsed_test_results` as the Data Engineering dbt monitoring agent.

Use the configured Etiyawiki/Jira MCP server to get issue `{{args}}` if Jira context is provided.

Follow the Data Engineer skill rules, especially:

- Local CLI Based Read-Only DB Access
- Sensitive Data Handling
- Jira / Rovo MCP Data Safety
- SQL Generation Rules
- Core Safety Rules
- Jira Workflow

## Purpose

This command analyzes dbt test and freshness results for Data Engineering and DWH OPS teams.

The main goals are:

- analyze the latest dbt test results from `DWH_OPR.parsed_test_results`
- identify important `warn` / `fail` records where `failures > 0`
- classify test types from `test_name`
- extract table and column information when possible
- classify duplicate, not_null, unique_combination, freshness, and unknown issues
- generate safe read-only validation SQL
- prepare Jira task/comment drafts when requested
- support proactive DWH Data Quality monitoring

This command must not:

- automatically create Jira tasks
- automatically add Jira comments
- automatically transition Jira status
- automatically add worklog
- modify schedule / cron / Jenkins / Dagster
- rerun ETL
- run `dbt run`, `dbt test`, or any dbt job automatically
- run DB write operations
- update control tables
- generate DDL/DML
- perform external actions without explicit user approval
- expose sensitive customer identifiers or credentials

---

## Current Manual Run Context

Currently, dbt test results may be refreshed manually by running a dbt test command in the relevant environment.

Example manual run pattern:

```bash
DBT_PROJECT_DIR="/app/dbt_project" \
DBT_PROFILES_DIR="/app/dbt_project/.dbt" \
dbt test \
--target prod
```

If the project uses a custom wrapper command such as `dbtf test`, keep the project-specific command as-is only when confirmed by the user or repository context.

After the dbt test command runs, results are loaded into dbt monitoring tables and `DWH_OPR.parsed_test_results` shows the latest available results.

Current assumptions:

- A schedule may not exist.
- The user may have run the tests manually.
- `parsed_test_results` may represent the latest manual or scheduled test run.
- Schedule / Jenkins / cron improvements may be suggested, but must not be applied automatically.
- Any schedule setup must be planned first and approved by the user.

---

## Usage

```text
/dbt-test-monitor

/dbt-test-monitor --last-24h
/dbt-test-monitor --last-7d
/dbt-test-monitor --severity warn
/dbt-test-monitor --severity fail
/dbt-test-monitor --table dwd_customer
/dbt-test-monitor --table dwh_microservice.dwd_customer
/dbt-test-monitor --jira DWHOPRS-123
```

Parameters can be combined:

```text
/dbt-test-monitor --last-7d --severity fail
/dbt-test-monitor --last-24h --table dwf_sales
/dbt-test-monitor --jira DWHOPRS-123 --severity warn
```

Default behavior:

```text
If no time range is provided, analyze the latest available parsed_test_results content.
If no severity is provided, check warn and fail together.
If no table is provided, check all tables.
```

---

## Expected View

Main monitoring view:

```text
DWH_OPR.parsed_test_results
```

Expected columns:

```text
table_name
test_name
status
failures
rows_affected
message
run_started_at
```

Required columns:

```text
table_name
test_name
status
run_started_at
```

Optional but useful columns:

```text
failures
rows_affected
message
```

If one of the required columns is missing, say:

```text
Bu view yapısı beklenen formatta değil. İlgili SQL çalıştırılabilir kabul edilmemelidir.
```

---

## Important Record Rule

Important dbt test findings are identified with this condition:

```sql
LOWER(status) IN ('warn', 'fail')
AND COALESCE(failures, 0) > 0
```

Rules:

- `status = warn` alone is not critical.
- `failures = 0` or `failures IS NULL` must not be marked as an important finding.
- Prioritize records with the highest `failures` values.
- If `failures` is very high, consider both possibilities:

  - it may be a real data quality issue
  - the test may be configured on the wrong business key or column

For unique tests, always raise this validation question:

```text
İlgili kolonun gerçekten business olarak unique olması bekleniyor mu?
```

Example:

```text
unique_dwd_billing_char_bill_acct_id
```

This indicates duplicates on `dwd_billing_char.bill_acct_id`.

However, it must be validated whether `bill_acct_id` is expected to be unique in that table.

---

## Validation Schema Rule

Because dbt adoption is still evolving, tested DWH tables often correspond to this schema:

```text
DWH_MICROSERVICE
```

Therefore, validation SQL should use this schema by default:

```text
DWH_MICROSERVICE.{{table_name}}
```

Example:

```text
parsed_test_results.table_name = dwd_billing_char
validation table = DWH_MICROSERVICE.dwd_billing_char
```

If the user provides a different schema, use the user-provided schema.

If the table name already includes a schema, do not add the schema again.

Example:

```text
dwh_microservice.dwd_customer```

---

## Test Name Parsing Rules

`test_name` contains the dbt test name. Test type, table, and column information are usually inferred from this field.

### 1. Unique Test

Example:

```text
unique_dwd_billing_char_bill_acct_id
```

Interpretation:

```text
test_category = unique
table_name = dwd_billing_char
column_name = bill_acct_id
```

Validation SQL:

```sql
SELECT
    bill_acct_id,
    COUNT(*) AS duplicate_count
FROM DWH_MICROSERVICE.dwd_billing_char
GROUP BY bill_acct_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

### 2. Not Null Test

Example:

```text
not_null_dwd_customer_org_name
```

Interpretation:

```text
test_category = not_null
table_name = dwd_customer
column_name = org_name
```

Validation SQL:

```sql
SELECT
    COUNT(*) AS total_count,
    COUNT_IF(org_name IS NULL) AS null_count
FROM DWH_MICROSERVICE.dwd_customer;
```

Sample SQL must avoid unnecessary sensitive columns:

```sql
SELECT
    org_name
FROM DWH_MICROSERVICE.dwd_customer
WHERE org_name IS NULL
LIMIT 100;
```

Avoid `SELECT *` when customer-sensitive columns may exist.

### 3. Unique Combination Test

Example:

```text
dbt_utils_unique_combination_of_columns_dwd_prod_ofr_char_val_prod_ofr_id__char_id__vrtl_bndl_id__char_val_id
```

Interpretation:

```text
test_category = unique_combination
table_name = dwd_prod_ofr_char_val
columns = prod_ofr_id, char_id, vrtl_bndl_id, char_val_id
```

Validation SQL:

```sql
SELECT
    prod_ofr_id,
    char_id,
    vrtl_bndl_id,
    char_val_id,
    COUNT(*) AS duplicate_count
FROM DWH_MICROSERVICE.dwd_prod_ofr_char_val
GROUP BY
    prod_ofr_id,
    char_id,
    vrtl_bndl_id,
    char_val_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

### 4. Freshness Test

Freshness tests are often defined on STG models using `ingestion_time`.

Typical logic:

```text
Has the related table received data in the last 48 hours?
```

Example test pattern:

```text
dbt_expectations.expect_row_values_to_have_recent_data
column_name: ingestion_time
datepart: hour
interval: 48
severity: warn
```

Interpretation:

```text
Freshness warn/fail may indicate that the table has not received data in the expected time window.
```

However, final validation must use the `message` field and the actual date/timestamp column in the table.

Validation SQL:

```sql
SELECT
    MAX(ingestion_time) AS max_ingestion_time,
    COUNT(*) AS row_count
FROM {{schema_name}}.{{table_name}};
```

Last 48 hours check:

```sql
SELECT
    COUNT(*) AS last_48h_row_count,
    MIN(ingestion_time) AS min_ingestion_time,
    MAX(ingestion_time) AS max_ingestion_time
FROM {{schema_name}}.{{table_name}}
WHERE ingestion_time >= DATEADD(hour, -48, CURRENT_TIMESTAMP());
```

---

## Important Freshness Rule

`run_started_at` is only the dbt test execution time.

```text
run_started_at tablonun son veri aldığı tarih değildir.
```

Therefore:

```text
Sadece run_started_at değerine bakarak "tabloya son 48 saatte veri gelmedi" sonucu çıkarma.
```

Freshness must be validated with:

```text
ingestion_time or another relevant data timestamp column on the actual table
```

If the view does not include fields such as `latest_data_date`, `max_ingestion_time`, `max_loaded_date`, `last_record_date`, or `last_update_date`, say:

```text
Freshness test warn/fail dönmüş görünüyor; ancak tablonun gerçek son veri tarihi ek metadata veya tablo üzerindeki tarih kolonu ile doğrulanmalıdır.
```

---

## Default Monitoring SQL Queries

### 1. Important warn/fail results

```sql
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
ORDER BY failures DESC, table_name, test_name;
```

### 2. Summary by status

```sql
SELECT
    LOWER(status) AS status,
    COUNT(*) AS record_count,
    COUNT(DISTINCT table_name) AS affected_table_count,
    COUNT(DISTINCT test_name) AS affected_test_count,
    SUM(COALESCE(failures, 0)) AS total_failures,
    MAX(run_started_at) AS latest_run_started_at
FROM DWH_OPR.parsed_test_results
WHERE LOWER(status) IN ('warn', 'fail')
  AND COALESCE(failures, 0) > 0
GROUP BY LOWER(status)
ORDER BY status;
```

### 3. Summary by table

```sql
SELECT
    table_name,
    LOWER(status) AS status,
    COUNT(*) AS test_count,
    SUM(COALESCE(failures, 0)) AS total_failures,
    MAX(run_started_at) AS latest_run_started_at
FROM DWH_OPR.parsed_test_results
WHERE LOWER(status) IN ('warn', 'fail')
  AND COALESCE(failures, 0) > 0
GROUP BY table_name, LOWER(status)
ORDER BY total_failures DESC, table_name;
```

### 4. Test category classification

```sql
SELECT
    table_name,
    test_name,
    CASE
        WHEN LOWER(test_name) LIKE '%freshness%'
          OR LOWER(test_name) LIKE '%recent_data%'
          OR LOWER(message) LIKE '%freshness%'
          OR LOWER(message) LIKE '%recent%'
          OR LOWER(message) LIKE '%48%'
          THEN 'freshness'
        WHEN LOWER(test_name) LIKE 'not_null_%'
          THEN 'not_null'
        WHEN LOWER(test_name) LIKE 'dbt_utils_unique_combination_of_columns_%'
          OR LOWER(test_name) LIKE '%unique_combination%'
          THEN 'unique_combination'
        WHEN LOWER(test_name) LIKE 'unique_%'
          THEN 'unique'
        ELSE 'other'
    END AS test_category,
    LOWER(status) AS status,
    failures,
    rows_affected,
    message,
    run_started_at
FROM DWH_OPR.parsed_test_results
WHERE LOWER(status) IN ('warn', 'fail')
  AND COALESCE(failures, 0) > 0
ORDER BY failures DESC, table_name, test_name;
```

### 5. Important results for a specific table

```sql
SELECT
    table_name,
    test_name,
    status,
    failures,
    rows_affected,
    message,
    run_started_at
FROM DWH_OPR.parsed_test_results
WHERE table_name = '{{table_name}}'

  AND LOWER(status) IN ('warn', 'fail')
  AND COALESCE(failures, 0) > 0
ORDER BY failures DESC, test_name;
```

### 6. Freshness-focused results

```sql
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
  AND (
        LOWER(test_name) LIKE '%freshness%'
        OR LOWER(test_name) LIKE '%recent_data%'
        OR LOWER(message) LIKE '%freshness%'
        OR LOWER(message) LIKE '%recent%'
        OR LOWER(message) LIKE '%48%'
        OR LOWER(message) LIKE '%hour%'
        OR LOWER(message) LIKE '%data%'
      )
ORDER BY failures DESC, table_name, test_name;
```
---

## Optional Read-Only Execution

This command may suggest read-only SQL execution only when needed.

If execution is requested or needed:

- prefer `dbconnect` when available
- use Snowflake CLI as a fallback
- follow the Local CLI Based Read-Only DB Access rules from the Data Engineer skill
- show the exact command before execution
- use preprod / non-prod first
- ask explicit approval before prod usage
- never run DDL/DML
- never run dbt jobs automatically

Preferred pattern:

```bash
dbconnect -c <connection_name> -q "<SELECT_SQL>"
```

Fallback pattern:

```bash
snow sql --connection <connection_name> --query "<SELECT_SQL>"
```

Default connection must not be assumed unless confirmed by user, repository context, or project registry.

If no connection is confirmed, ask the user for the connection name.

---

## Validation SQL Templates

### 1. Unique Duplicate Check

Usage:

```text
unique_{{table_name}}_{{column_name}}
```

SQL:

```sql
SELECT
    {{column_name}},
    COUNT(*) AS duplicate_count
FROM DWH_MICROSERVICE.{{table_name}}
GROUP BY {{column_name}}
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

Duplicate group count:

```sql
SELECT COUNT(*) AS duplicate_key_count
FROM (
    SELECT {{column_name}}
    FROM DWH_MICROSERVICE.{{table_name}}
    GROUP BY {{column_name}}
    HAVING COUNT(*) > 1
);
```

Affected duplicate row count:

```sql
SELECT SUM(cnt) AS affected_duplicate_rows
FROM (
    SELECT {{column_name}}, COUNT(*) AS cnt
    FROM DWH_MICROSERVICE.{{table_name}}
    GROUP BY {{column_name}}
    HAVING COUNT(*) > 1
);
```

Example:

```sql
SELECT
    bill_acct_id,
    COUNT(*) AS duplicate_count
FROM DWH_MICROSERVICE.dwd_billing_char
GROUP BY bill_acct_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

### 2. Not Null Check

Usage:

```text
not_null_{{table_name}}_{{column_name}}
```

SQL:

```sql
SELECT
    COUNT(*) AS total_count,
    COUNT_IF({{column_name}} IS NULL) AS null_count
FROM DWH_MICROSERVICE.{{table_name}};
```

Null sample:

```sql
SELECT
    {{column_name}}
FROM DWH_MICROSERVICE.{{table_name}}
WHERE {{column_name}} IS NULL
LIMIT 100;
```

Avoid `SELECT *` when the table may contain sensitive customer data.

### 3. Unique Combination Check

Usage:

```text
dbt_utils_unique_combination_of_columns_{{table_name}}_{{column_1}}__{{column_2}}__{{column_3}}
```

SQL:

```sql
SELECT
    {{column_1}},
    {{column_2}},
    {{column_3}},
    COUNT(*) AS duplicate_count
FROM DWH_MICROSERVICE.{{table_name}}
GROUP BY
    {{column_1}},
    {{column_2}},
    {{column_3}}
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

Column count must be adjusted according to `test_name`.

### 4. Freshness Validation

Freshness is usually validated through `ingestion_time` for STG tables.

SQL:

```sql
SELECT
    MAX(ingestion_time) AS max_ingestion_time,
    COUNT(*) AS total_count
FROM {{schema_name}}.{{table_name}};
```

Last 48 hours:

```sql
SELECT
    COUNT(*) AS last_48h_row_count,
    MIN(ingestion_time) AS min_ingestion_time,
    MAX(ingestion_time) AS max_ingestion_time
FROM {{schema_name}}.{{table_name}}
WHERE ingestion_time >= DATEADD(hour, -48, CURRENT_TIMESTAMP());
```

If `ingestion_time` does not exist:

```text
Freshness doğrulaması için uygun tarih kolonu kullanıcıdan istenmelidir.
```

---

## Classification Rules

### Freshness Issue

Classify as freshness when:

- `test_name` contains `freshness` or `recent_data`
- `message` contains `freshness`, `recent`, `48`, `hour`, or `data`
- the test appears related to `dbt_expectations.expect_row_values_to_have_recent_data`

Always state:

```text
Freshness ihlali görünüyor. Ancak run_started_at test çalışma zamanıdır; tablonun son veri tarihi değildir. Gerçek son veri tarihi ingestion_time veya uygun date kolonu ile doğrulanmalıdır.
```

### Not Null Issue

Classify as not_null when:

- `test_name` starts with `not_null_`
- `message` mentions null values

Output should include:

- table name
- column name
- null count SQL
- safe sample SQL

### Unique Issue

Classify as unique when:

- `test_name` starts with `unique_`
- it is not a unique_combination test

Output should include:

- table name
- column name
- duplicate group SQL
- affected duplicate rows SQL

Also state:

```text
Bu kolonun business olarak gerçekten unique olması bekleniyor mu doğrulanmalıdır.
```

### Unique Combination Issue

Classify as unique_combination when:

- `test_name` contains `dbt_utils_unique_combination_of_columns`
- `test_name` contains `unique_combination`

Output should include:

- table name
- column combination
- duplicate combination SQL

### Test Configuration Risk

Mention test configuration risk when:

- `failures` is very high
- a unique test is defined on a naturally repeating column
- a not_null test is defined on a column that may be nullable by business rules
- the test was newly added and produced a very high failure count in the first run

Example:

```text
Bu bulgu gerçek data quality problemi olabilir; ancak failures değeri çok yüksek olduğu için testin doğru business key/kolon üzerine tanımlandığı ayrıca doğrulanmalıdır.
```

### Other / Unknown

If the test type cannot be identified, say:

```text
Test tipi net belirlenemedi. test_name ve message alanları manuel incelenmelidir.
```

If the column cannot be safely parsed, say:

```text
Kolon bilgisi test_name içinden güvenli şekilde çıkarılamadı. YAML test tanımı kontrol edilmelidir.
```

---

## Jira Draft Format

If the user asks for a Jira task/comment draft, use this Turkish format:

```text
Başlık:
[dbt-test-monitor] {{table_name}} - {{test_category}} {{status}} - failures: {{failures}}

Açıklama:
DWH_OPR.parsed_test_results view'ında dbt test/freshness monitoring sonucunda aşağıdaki bulgu tespit edilmiştir.

Detay:
- Tablo: {{table_name}}
- Doğrulama şeması: DWH_MICROSERVICE
- Test: {{test_name}}
- Test kategorisi: {{test_category}}
- Kolon / kolon kombinasyonu: {{columns}}
- Status: {{status}}
- Failures: {{failures}}
- Rows affected: {{rows_affected}}
- Run started at: {{run_started_at}}
- Message: {{message}}

İlk Değerlendirme:
{{root_cause_hypothesis}}

Önerilen Kontroller:
1. DWH_MICROSERVICE.{{table_name}} üzerinde önerilen SELECT doğrulama sorguları çalıştırılmalıdır.
2. Test unique ise ilgili kolonun gerçekten business key olup olmadığı doğrulanmalıdır.
3. Test not_null ise ilgili kolonun business olarak nullable olup olmadığı doğrulanmalıdır.
4. Test freshness ise ingestion_time veya uygun date kolonu ile son veri tarihi kontrol edilmelidir.
5. Eğer kaynakta veri doğru ama DWH_MICROSERVICE tarafında bozuksa dbt model / upstream ETL logic incelenmelidir.
6. Eğer kaynakta da problem varsa kaynak sistem ekibine yönlendirme yapılmalıdır.

Not:
Bu task otomatik oluşturulmamıştır. AI tarafından taslak olarak hazırlanmıştır.
```

Do not automatically create Jira tasks or comments.

If Jira write action is requested, route through `/jira` or ask for explicit approval.

---

## Safety Rules

Follow the centralized Data Engineer skill safety rules.

This command must especially enforce:

- Always respond in Turkish.
- Use only monitoring view results, Jira context, and user-provided context.
- Mask sensitive values in responses and Jira drafts.
- Suggest only read-only SELECT SQL.
- Do not generate DDL/DML.
- Do not run SQL automatically without explicit user approval.
- Do not use production DB connections without explicit approval.
- Do not run `dbt run`, `dbt test`, `dbtf test`, or any dbt job automatically.
- Do not rerun ETL.
- Do not update control tables.
- Do not modify Jenkins, Dagster, cron, or schedule settings.
- Do not automatically create Jira tasks.
- Do not automatically add Jira comments.
- Do not automatically transition Jira status.
- Do not automatically add worklog.
- Do not mark `failures <= 0` as important.
- Do not treat `run_started_at` as the table’s last data date.
- Do not claim root cause is confirmed unless supported by evidence.
- If `DWH_MICROSERVICE` is not the correct validation schema, ask the user to confirm the schema.
- If Jira context exists and issue status is `Cancelled`, `Closed`, `Resolved`, or `Done`, stop and ask whether exceptional action is required.

---

## Output Format

Always respond in Turkish.

Use this structure:

```text
## Genel Özet

- Run zamanı:
- Toplam önemli warn/fail sayısı:
- Toplam warn:
- Toplam fail:
- Etkilenen tablo sayısı:
- Toplam failures:
- En yüksek failures üreten tablo/test:
- Kritik freshness bulgusu:
- Test config riski olan bulgu var mı:

## Öncelikli Bulgular

| Öncelik | Tablo | Test Tipi | Kolon/Kombinasyon | Status | Failures | Değerlendirme |
|---:|---|---|---|---|---:|---|

## Tablo Bazlı Detay

| Tablo | Test | Status | Failures | Message |
|---|---|---|---:|---|

## Sınıflandırma

- Freshness issue:
- Not null issue:
- Unique issue:
- Unique combination issue:
- Test config riski:
- Other:

## Olası Nedenler

Kök nedeni kesinmiş gibi yazma. Hipotez olarak belirt.

Örnek:
- Kaynakta duplicate oluşmuş olabilir.
- DWH model join logic'i çoklama yaratıyor olabilir.
- Incremental yükleme tekrar kayıt üretmiş olabilir.
- Kolon business olarak nullable olabilir.
- Test yanlış business key üzerine tanımlanmış olabilir.
- STG tabloya ingestion son 48 saatte gelmemiş olabilir.
- Upstream source/ETL gecikmiş olabilir.

## Doğrulama SQL'leri

Sadece SELECT SQL öner.

## Jira Task/Comment Taslağı

Kullanıcı isterse veya Jira context varsa task/comment taslağı hazırla.
Otomatik task açma veya yorum ekleme.```
