---
description: DWH_OPR.parsed_test_results view'ındaki dbt test sonuçlarını analiz eder, sınıflandırır ve raporlar
---

DWH_OPR.parsed_test_results view'ındaki dbt test ve freshness warn/fail sonuçlarını analiz eden monitoring agent.

Use the etiyawiki MCP server to get issue {{args}} if a Jira context is provided.

## Purpose

Bu command, Data Engineering ve DWH OPS ekipleri için dbt test ve freshness sonuçlarını analiz etmek amacıyla tasarlanmıştır.

Destekler:

- dbt test sonuçlarını okuma ve sınıflandırma
- freshness warn/fail sonuçlarını analiz etme
- test kategorilerine göre gruplama
- saf SELECT sorguları ile veri çekme
- Jira task taslağı oluşturma
- rapor ve özet çıkarma

Bu command asla:

- otomatik Jira task açmaz
- schedule/cron değiştirmez
- ETL rerun yapmaz
- DB write işlemi yapmaz
- control table güncellemez

---

## Kullanım

```text
/dbt-test-monitor                  → Son 24 saatteki tüm warn/fail sonuçlarını listele
/dbt-test-monitor --last-1h        → Son 1 saat
/dbt-test-monitor --last-7d        → Son 7 gün
/dbt-test-monitor --severity warn  → Sadece warn seviyesi
/dbt-test-monitor --severity fail  → Sadece fail seviyesi
/dbt-test-monitor --model my_model → Belirli bir model için
/dbt-test-monitor --source my_source → Belirli bir source için
/dbt-test-monitor --jira PROJ-123  → Belirtilen issue context'inde çalıştır
```

Parametreler birleştirilebilir:

```text
/dbt-test-monitor --last-7d --severity fail
/dbt-test-monitor --last-1h --source mssql_bss
```

---

## SQL Sorguları

### 1. Son N saatteki warn/fail sonuçları

```sql
SELECT *
FROM DWH_OPR.parsed_test_results
WHERE executed_at >= SYSDATE - INTERVAL '{{hours}}' HOUR
  AND result_type IN ('warn', 'fail')
ORDER BY executed_at DESC;
```

### 2. Test kategorilerine göre dağılım

```sql
SELECT
  result_type,
  test_type,
  COUNT(*) AS adet,
  MIN(executed_at) AS ilk_gorulme,
  MAX(executed_at) AS son_gorulme
FROM DWH_OPR.parsed_test_results
WHERE executed_at >= SYSDATE - INTERVAL '{{hours}}' HOUR
  AND result_type IN ('warn', 'fail')
GROUP BY result_type, test_type
ORDER BY result_type, test_type;
```

### 3. Model bazında detay

```sql
SELECT
  model_name,
  result_type,
  test_type,
  COUNT(*) AS adet,
  MAX(executed_at) AS son_gorulme
FROM DWH_OPR.parsed_test_results
WHERE executed_at >= SYSDATE - INTERVAL '{{hours}}' HOUR
  AND result_type IN ('warn', 'fail')
GROUP BY model_name, result_type, test_type
ORDER BY adet DESC;
```

### 4. Belirli bir model için detay

```sql
SELECT *
FROM DWH_OPR.parsed_test_results
WHERE model_name = '{{model_name}}'
  AND executed_at >= SYSDATE - INTERVAL '{{hours}}' HOUR
  AND result_type IN ('warn', 'fail')
ORDER BY executed_at DESC;
```

### 5. Source freshness sonuçları

```sql
SELECT *
FROM DWH_OPR.parsed_test_results
WHERE source_name IS NOT NULL
  AND executed_at >= SYSDATE - INTERVAL '{{hours}}' HOUR
  AND result_type IN ('warn', 'fail')
ORDER BY executed_at DESC;
```

### 6. Belirli bir source için freshness sonuçları

```sql
SELECT *
FROM DWH_OPR.parsed_test_results
WHERE source_name = '{{source_name}}'
  AND executed_at >= SYSDATE - INTERVAL '{{hours}}' HOUR
  AND result_type IN ('warn', 'fail')
ORDER BY executed_at DESC;
```

### 7. Özet rapor

```sql
SELECT
  result_type,
  COUNT(*) AS adet,
  COUNT(DISTINCT model_name) AS etkilenen_model,
  COUNT(DISTINCT test_type) AS test_turu_sayisi
FROM DWH_OPR.parsed_test_results
WHERE executed_at >= SYSDATE - INTERVAL '{{hours}}' HOUR
  AND result_type IN ('warn', 'fail')
GROUP BY result_type;
```

---

## Çıktı Formatı

### Rapor Özeti

1. **Dönem**: Son N saat/gün
2. **Toplam Warn**: X
3. **Toplam Fail**: Y
4. **En Çok Hata Alan Modeller**: (top 5)
5. **Test Türü Dağılımı**: (kategoriler)
6. **Source Freshness Durumu**: (varsa)
7. **Kronik Sorunlar**: 24 saatten uzun süredir devam eden fail'ler

### Sınıflandırma

Her sonuç için otomatik sınıflandırma:

- **Kronik**: Aynı model/test 24+ saattir fail durumunda
- **Yeni**: Son 1 saat içinde ilk kez fail olmuş
- **Aralıklı**: Son 24 saat içinde warn/fail görmüş ama şu an yok
- **Flapping**: Aynı model/test sürekli warn/fail arasında gidip geliyor

### Jira Task Taslağı

Kullanıcı onayı olmadan Jira task'i oluşturulmaz. Sadece aşağıdaki formatta **taslak** üretilir:

```text
Jira Task Taslağı:
  Başlık: [dbt-monitor] {{model_name}} - {{test_type}} fail
  Proje: DWH
  Tip: Task
  Öncelik: {{priority}}
  Açıklama:
    - Model: {{model_name}}
    - Test: {{test_type}}
    - Sonuç: {{result_type}}
    - İlk Görülme: {{first_seen}}
    - Son Görülme: {{last_seen}}
    - Süre: {{duration}}
    - Detay: {{error_message}}
```

---

## Safety Rules

- Sadece SELECT sorguları çalıştırılır. INSERT/UPDATE/DELETE/MERGE asla kullanılmaz.
- Otomatik Jira task açılmaz.
- Otomatik ETL rerun yapılmaz.
- Schedule/cron değiştirilmez.
- Control table güncellenmez.
- Tüm öneriler kullanıcı onayına sunulur.
- Jira context'i varsa, issue statüsü Cancelled/Closed/Resolved/Done ise önce kullanıcıya sorulur.
