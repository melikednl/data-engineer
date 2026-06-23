---
## description: DWH_OPR.parsed_test_results view'ındaki dbt test ve freshness sonuçlarını analiz eder, sınıflandırır ve raporlar
---

DWH_OPR.parsed_test_results view'ındaki dbt test ve freshness warn/fail sonuçlarını analiz eden monitoring agent.

Use the connected Atlassian/Etiyawiki MCP server to get issue {{args}} if a Jira context is provided.

## Purpose

Bu command, Data Engineering ve DWH OPS ekipleri için dbt test ve freshness sonuçlarını analiz etmek amacıyla tasarlanmıştır.

Temel amaç:

* dbt test sonuçlarını analiz etmek
* freshness warn/fail sonuçlarını takip etmek
* status = warn/fail olan kayıtları tablo ve test bazında gruplamak
* freshness ihlallerini kritik olarak işaretlemek
* güvenli SELECT sorguları önermek
* Jira task/comment taslağı hazırlamak
* proaktif data quality monitoring sürecine destek olmak

Bu command asla:

* otomatik Jira task açmaz
* otomatik Jira status değiştirmez
* schedule/cron/Jenkins/Dagster değiştirmez
* ETL rerun yapmaz
* dbt job çalıştırmaz
* DB write işlemi yapmaz
* control table güncellemez

---

## Kullanım

```text
/dbt-test-monitor
/dbt-test-monitor --last-1h
/dbt-test-monitor --last-24h
/dbt-test-monitor --last-7d
/dbt-test-monitor --severity warn
/dbt-test-monitor --severity fail
/dbt-test-monitor --table dwd_customer
/dbt-test-monitor --jira DWHOPRS-123
```

Parametreler birleştirilebilir:

```text
/dbt-test-monitor --last-7d --severity fail
/dbt-test-monitor --last-24h --table dwf_sales
/dbt-test-monitor --jira DWHOPRS-123 --severity warn
```

Varsayılan davranış:

```text
Eğer süre belirtilmezse son 24 saat kontrol edilir.
Eğer severity belirtilmezse warn ve fail birlikte kontrol edilir.
Eğer tablo belirtilmezse tüm tablolar kontrol edilir.
```

---

## Expected View Columns

Bu command varsayılan olarak `DWH_OPR.parsed_test_results` view'ında aşağıdaki kolonları bekler:

```text
table_name
test_name
status
failures
rows_affected
message
run_started_at
```

Önemli:

```text
run_started_at testin çalışma zamanıdır.
run_started_at tablonun son veri aldığı zamanı garanti etmez.
```

Bu nedenle 48 saat veri gelmedi yorumu yapılacaksa, view içinde veya ek metadata içinde tablonun son veri tarihi de bulunmalıdır.

Eğer aşağıdaki kolonlardan biri mevcut değilse, bunu açıkça belirt ve ilgili SQL'i çalıştırılabilir kabul etme:

```text
table_name
test_name
status
run_started_at
```

Opsiyonel kolonlar:

```text
failures
rows_affected
message
```

---

## Important Freshness Rule

Freshness analizi yapılırken dikkat edilmesi gereken en önemli kural:

```text
run_started_at sadece dbt testinin çalıştığı zamandır.
Tablonun son veri aldığı tarih değildir.
```

Bu yüzden:

```text
Eğer latest_data_date, max_loaded_date, last_record_date, last_update_date veya benzeri bir metadata yoksa,
"tabloya son 48 saatte veri gelmedi" sonucu kesin olarak söylenmemelidir.
```

Bu durumda şöyle ifade et:

```text
Freshness test warn/fail dönmüş görünüyor; ancak tablonun gerçek son veri tarihi view içinde bulunmadığı için 48 saat veri gelmedi sonucu ek metadata ile doğrulanmalıdır.
```

---

## Default SQL Queries

### 1. Son N saatteki warn/fail sonuçları

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
WHERE run_started_at >= DATEADD(hour, -{{hours}}, CURRENT_TIMESTAMP())
  AND LOWER(status) IN ('warn', 'fail')
ORDER BY run_started_at DESC, table_name, test_name;
```

### 2. Status bazında özet

```sql
SELECT
    LOWER(status) AS status,
    COUNT(*) AS record_count,
    COUNT(DISTINCT table_name) AS affected_table_count,
    COUNT(DISTINCT test_name) AS affected_test_count,
    MIN(run_started_at) AS first_seen,
    MAX(run_started_at) AS last_seen
FROM DWH_OPR.parsed_test_results
WHERE run_started_at >= DATEADD(hour, -{{hours}}, CURRENT_TIMESTAMP())
  AND LOWER(status) IN ('warn', 'fail')
GROUP BY LOWER(status)
ORDER BY status;
```

### 3. Tablo bazında özet

```sql
SELECT
    table_name,
    LOWER(status) AS status,
    COUNT(*) AS record_count,
    COUNT(DISTINCT test_name) AS affected_test_count,
    SUM(COALESCE(failures, 0)) AS total_failures,
    MAX(run_started_at) AS last_seen
FROM DWH_OPR.parsed_test_results
WHERE run_started_at >= DATEADD(hour, -{{hours}}, CURRENT_TIMESTAMP())
  AND LOWER(status) IN ('warn', 'fail')
GROUP BY table_name, LOWER(status)
ORDER BY record_count DESC, table_name;
```

### 4. Test bazında dağılım

```sql
SELECT
    CASE
        WHEN LOWER(test_name) LIKE '%freshness%' OR LOWER(message) LIKE '%freshness%' THEN 'freshness'
        WHEN LOWER(test_name) LIKE '%not_null%' THEN 'not_null'
        WHEN LOWER(test_name) LIKE '%unique_combination%' 
          OR LOWER(test_name) LIKE '%unique_combination_of_columns%' THEN 'unique_combination'
        WHEN LOWER(test_name) LIKE '%unique%' THEN 'unique'
        ELSE 'other'
    END AS test_category,
    LOWER(status) AS status,
    COUNT(*) AS record_count,
    COUNT(DISTINCT table_name) AS affected_table_count,
    SUM(COALESCE(failures, 0)) AS total_failures,
    MAX(run_started_at) AS last_seen
FROM DWH_OPR.parsed_test_results
WHERE run_started_at >= DATEADD(hour, -{{hours}}, CURRENT_TIMESTAMP())
  AND LOWER(status) IN ('warn', 'fail')
GROUP BY
    CASE
        WHEN LOWER(test_name) LIKE '%freshness%' OR LOWER(message) LIKE '%freshness%' THEN 'freshness'
        WHEN LOWER(test_name) LIKE '%not_null%' THEN 'not_null'
        WHEN LOWER(test_name) LIKE '%unique_combination%' 
          OR LOWER(test_name) LIKE '%unique_combination_of_columns%' THEN 'unique_combination'
        WHEN LOWER(test_name) LIKE '%unique%' THEN 'unique'
        ELSE 'other'
    END,
    LOWER(status)
ORDER BY record_count DESC;
```

### 5. Belirli bir tablo için detay

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
  AND run_started_at >= DATEADD(hour, -{{hours}}, CURRENT_TIMESTAMP())
  AND LOWER(status) IN ('warn', 'fail')
ORDER BY run_started_at DESC, test_name;
```

### 6. Freshness odaklı sonuçlar

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
WHERE run_started_at >= DATEADD(hour, -{{hours}}, CURRENT_TIMESTAMP())
  AND LOWER(status) IN ('warn', 'fail')
  AND (
        LOWER(test_name) LIKE '%freshness%'
        OR LOWER(message) LIKE '%freshness%'
        OR LOWER(message) LIKE '%48%'
        OR LOWER(message) LIKE '%hour%'
        OR LOWER(message) LIKE '%data%'
      )
ORDER BY run_started_at DESC, table_name, test_name;
```

### 7. Kronikleşen testler

```sql
SELECT
    table_name,
    test_name,
    LOWER(status) AS status,
    COUNT(*) AS occurrence_count,
    MIN(run_started_at) AS first_seen,
    MAX(run_started_at) AS last_seen,
    SUM(COALESCE(failures, 0)) AS total_failures
FROM DWH_OPR.parsed_test_results
WHERE run_started_at >= DATEADD(hour, -{{hours}}, CURRENT_TIMESTAMP())
  AND LOWER(status) IN ('warn', 'fail')
GROUP BY table_name, test_name, LOWER(status)
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC, last_seen DESC;
```

---

## Classification Rules

Her sonucu aşağıdaki kategorilerden biriyle sınıflandır:

### Freshness Issue

Şu durumlarda freshness olarak sınıflandır:

```text
test_name veya message içinde freshness ifadesi varsa
message içinde son veri tarihi / 48 saat / expected freshness benzeri ifade varsa
```

Ama kesin root cause yazma. Şöyle yaz:

```text
Freshness ihlali görünüyor. Tablonun gerçek son veri tarihi ek metadata ile doğrulanmalıdır.
```

### Not Null Issue

Şu durumlarda not_null olarak sınıflandır:

```text
test_name içinde not_null varsa
message null değerlerle ilgiliyse
```

Olası nedenler:

```text
Kaynakta ilgili alan null geliyor olabilir.
Join/filter sonrası alan boş kalıyor olabilir.
Mapping eksik olabilir.
Yeni kayıt tipi için kolon dolmuyor olabilir.
```

### Unique Issue

Şu durumlarda unique olarak sınıflandır:

```text
test_name içinde unique varsa
unique_combination değilse
```

Olası nedenler:

```text
Kaynakta duplicate oluşmuş olabilir.
Join çoklama yaratıyor olabilir.
Incremental model eski kayıtları temizlemiyor olabilir.
Tekilleştirme logic'i eksik olabilir.
```

### Unique Combination Issue

Şu durumlarda unique_combination olarak sınıflandır:

```text
test_name içinde unique_combination veya unique_combination_of_columns varsa
```

Olası nedenler:

```text
Birden fazla kolon kombinasyonunda duplicate oluşmuş olabilir.
Join ilişkisi 1-N çalışmış olabilir.
Business key yanlış belirlenmiş olabilir.
Incremental yükleme tekrar kayıt üretmiş olabilir.
```

### Other / Unknown

Test tipi net çıkarılamıyorsa:

```text
Test tipi net belirlenemedi. test_name ve message alanları manuel incelenmelidir.
```

---

## Output Format

Her zaman Türkçe cevap ver.

Çıktı yapısı:

```text
## Genel Özet

- Kontrol edilen dönem:
- Toplam warn sayısı:
- Toplam fail sayısı:
- Etkilenen tablo sayısı:
- Etkilenen test sayısı:
- Kritik freshness bulgusu:
- Kronikleşen sorun var mı:

## Kritik Bulgular

| Tablo | Test | Status | Failures | Son Görülme | Değerlendirme |
|---|---|---|---:|---|---|

## Tablo Bazlı Detay

| Tablo | Test | Status | Failures | Message |
|---|---|---|---:|---|

## Sınıflandırma

- Freshness issue:
- Not null issue:
- Unique issue:
- Unique combination issue:
- Other:

## Olası Nedenler

Kök nedeni kesinmiş gibi yazma. Hipotez olarak belirt.

Örnek:
- Source data delay olabilir.
- Upstream ETL/dbt model çalışmamış olabilir.
- Join/filter logic bazı kayıtları dışarıda bırakıyor olabilir.
- Incremental load tekrar/eksik kayıt üretmiş olabilir.
- Test config güncellenmiş olabilir.

## Önerilen Kontroller

Sadece SELECT SQL öner.

## Jira Task Taslağı

Kullanıcı isterse veya Jira context varsa task/comment taslağı hazırla.
Otomatik task açma.
```

---

## Suggested SELECT Checks

### Tabloya son kayıt ne zaman gelmiş olabilir?

Bu SQL her tabloda çalışmayabilir. Tarih kolonu tabloya göre uyarlanmalıdır:

```sql
SELECT
    MAX({{date_column}}) AS max_data_date,
    COUNT(*) AS row_count
FROM {{table_name}};
```

### Freshness doğrulama için örnek

```sql
SELECT
    COUNT(*) AS last_48h_row_count,
    MIN({{date_column}}) AS min_date,
    MAX({{date_column}}) AS max_date
FROM {{table_name}}
WHERE {{date_column}} >= DATEADD(hour, -48, CURRENT_TIMESTAMP());
```

### Not null kontrolü

```sql
SELECT
    COUNT(*) AS total_count,
    COUNT_IF({{column_name}} IS NULL) AS null_count
FROM {{table_name}};
```

### Unique kontrolü

```sql
SELECT
    {{column_name}},
    COUNT(*) AS duplicate_count
FROM {{table_name}}
GROUP BY {{column_name}}
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

### Unique combination kontrolü

```sql
SELECT
    {{column_1}},
    {{column_2}},
    COUNT(*) AS duplicate_count
FROM {{table_name}}
GROUP BY {{column_1}}, {{column_2}}
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

---

## Jira Draft Format

Kullanıcı Jira task/comment taslağı isterse aşağıdaki formatı kullan:

```text
Başlık:
[dbt-test-monitor] {{table_name}} - {{test_category}} {{status}}

Açıklama:
DWH_OPR.parsed_test_results view'ında dbt test/freshness monitoring sonucunda aşağıdaki bulgu tespit edilmiştir.

Detay:
- Tablo: {{table_name}}
- Test: {{test_name}}
- Test kategorisi: {{test_category}}
- Status: {{status}}
- Failures: {{failures}}
- Rows affected: {{rows_affected}}
- Run started at: {{run_started_at}}
- Message: {{message}}

İlk Değerlendirme:
{{root_cause_hypothesis}}

Önerilen Kontroller:
1. İlgili dbt model/test sonucunun son run detayları kontrol edilmeli.
2. Tablonun son veri tarihi uygun date kolonu ile doğrulanmalı.
3. Upstream model/job/procedure başarısı kontrol edilmeli.
4. Freshness ise kaynak veri gecikmesi ihtimali değerlendirilmelidir.
5. Source tarafında veri varsa ancak DWH tarafında yoksa DWH/ETL akışı incelenmelidir.

Not:
Bu task otomatik oluşturulmamıştır. AI tarafından taslak olarak hazırlanmıştır.
```

---

## Safety Rules

* Sadece SELECT sorguları öner.
* INSERT/UPDATE/DELETE/MERGE/TRUNCATE/DROP/CREATE işlemleri önerme.
* Otomatik Jira task açma.
* Otomatik Jira comment ekleme.
* Otomatik Jira status değiştirme.
* Otomatik worklog girme.
* Otomatik ETL rerun yapma.
* Otomatik dbt run/test çalıştırma.
* Jenkins/Dagster/cron/schedule değiştirme.
* Control table güncelleme.
* Root cause kesinmiş gibi yazma; kanıt yoksa hipotez olarak belirt.
* Freshness analizinde run_started_at alanını tablonun son veri tarihi gibi yorumlama.
* Kullanıcı onayı olmadan hiçbir dış sistemde aksiyon alma.
* Jira context'i varsa ve issue statüsü Cancelled/Closed/Resolved/Done ise işlem yapmadan önce kullanıcıya sor.
