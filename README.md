# Data Engineer — OpenCode & Windsurf/Devin CLI Pack

Etiyawiki/Jira task analizi, DWH/ETL problem inceleme, repo aksiyonları, dbt test/freshness monitoring, Jira süreçleri ve opsiyonel lokal DB bağlantı standardizasyonu için hazırlanmış Data Engineering AI workflow paketidir.

Bu paket şu araçlarla kullanılabilir:

* OpenCode
* Windsurf / Devin CLI

Ayrıca opsiyonel olarak Snowflake, PostgreSQL ve MongoDB bağlantıları için lokal `dbconnect` helper kurulumu desteklenir.

> Not: Bu repository şu an test/MVP amacıyla kişisel GitHub hesabı altında tutulmaktadır. Takım veya şirket geneli kullanım için repository’nin ortak bir organization hesabı altına taşınması ve `install.sh` içindeki `REPO` değerinin güncellenmesi önerilir.

---

## 1. Fresh Setup — Sıfırdan Kurulum

Bu bölüm, bilgisayarında henüz WSL/Ubuntu, Git, OpenCode veya proje repoları olmayan kullanıcılar içindir.

---

## 1.1 WSL / Ubuntu Kurulumu

Windows PowerShell’i **Run as Administrator** olarak açın ve çalıştırın:

```powershell
wsl --install -d Ubuntu
```

Kurulum sonrası bilgisayarı yeniden başlatmanız gerekebilir.

Ubuntu ilk açıldığında sizden Linux kullanıcı adı ve şifre ister.

Kurulum kontrolü:

```bash
wsl --status
```

Ubuntu terminali içinde:

```bash
whoami
pwd
```

---

## 1.2 Ubuntu İçinde Temel Araçları Kurma

Ubuntu terminalinde:

```bash
sudo apt update
sudo apt install -y git curl unzip ca-certificates build-essential
```

Git kontrolü:

```bash
git --version
```

Git kullanıcı bilgisi:

```bash
git config --global user.name "Ad Soyad"
git config --global user.email "ad.soyad@gmail.com"
```

Kontrol:

```bash
git config --global --list
```

---

## 1.3 VS Code / WSL Kullanımı

Windows tarafında VS Code kurulu olmalıdır.

VS Code extension olarak şunu kurun:

```text
WSL - Microsoft
```

Ubuntu terminalinden VS Code açma testi:

```bash
code --version
```

Proje klasörlerini sonradan şöyle açabilirsiniz:

```bash
code ~/codes
```

---

## 1.4 Bitbucket SSH Erişimi

Önce SSH key var mı kontrol edin:

```bash
ls -la ~/.ssh
```

Eğer `id_ed25519.pub` yoksa yeni SSH key oluşturun:

```bash
ssh-keygen -t ed25519 -C "ad.soyad@gmail.com"
```

Sorular geldiğinde Enter ile geçebilirsiniz.

Public key’i görüntüleyin:

```bash
cat ~/.ssh/id_ed25519.pub
```

Çıkan değeri komple kopyalayın.

Bitbucket üzerinde:

```text
Personal settings
→ SSH keys
→ Add key
```

alanına ekleyin.

SSH bağlantı testi:

```bash
ssh -T git@bitbucket2.etiya.com
```

İlk bağlantıda şu soru gelebilir:

```text
Are you sure you want to continue connecting?
```

`yes` yazıp Enter’a basın.

Başarılı bağlantıdan sonra repo clone işlemlerine geçebilirsiniz.

> Eğer `Permission denied (publickey)` hatası alınırsa SSH key Bitbucket’a eklenmemiştir veya kullanıcının repo yetkisi yoktur.

---

## 1.5 Proje Klasörlerini Oluşturma

Ubuntu terminalinde:

```bash
mkdir -p ~/codes
cd ~/codes
```

Önerilen klasör yapısı:

```text
~/codes/
  darwin/
  fizz/
  maya/
  data-engineer/
```

---

## 1.6 Bitbucket Reposlarını Clone Etme

Darwin:

```bash
cd ~/codes
git clone <DARWIN_REPO_SSH_URL> darwin
```

Fizz:

```bash
cd ~/codes
git clone <FIZZ_REPO_SSH_URL> fizz
```

Maya için ilgili repo URL’si ile aynı mantık kullanılabilir:

```bash
cd ~/codes
git clone <MAYA_REPO_SSH_URL> maya
```

Kontrol:

```bash
ls ~/codes
```

Beklenen örnek:

```text
darwin
fizz
maya
```

VS Code’da tüm klasörü açmak için:

```bash
code ~/codes
```

---

## 2. OpenCode Kurulumu

Ubuntu terminalinde:

```bash
curl -fsSL https://opencode.ai/install | bash
```

Kurulum sonrası terminali kapatıp açın veya:

```bash
source ~/.bashrc
```

Kontrol:

```bash
opencode --version
```

OpenCode’u başlatmak için:

```bash
opencode
```

---

## 3. Data Engineer Pack Kurulumu

### 3.1 Tek Komut — Otomatik Algılama

CLI otomatik algılanır. Devin CLI varsa Devin/Windsurf tarafına, yoksa OpenCode tarafına kurar:

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | bash
```

---

### 3.2 OpenCode İçin Kurulum

Global kurulum önerilir. Böylece tüm projelerde kullanılabilir:

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | bash -s -- --opencode --global
```

Global kurulum path’leri:

```text
~/.config/opencode/commands/
~/.config/opencode/skills/
```

Proje bazlı kurulum:

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | bash -s -- --opencode --project
```

Kurulum kontrolü:

```bash
find ~/.config/opencode -maxdepth 4 -type f | sort | grep -E "analyze|investigate|execute|repo|jira|review|dbt-test-monitor|data-engineer"
```

---

### 3.3 Windsurf / Devin CLI İçin Kurulum

Global kurulum:

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | bash -s -- --devin --global
```

Global kurulum path’leri:

```text
~/.codeium/windsurf/global_workflows/
~/.codeium/windsurf/skills/
```

Proje bazlı kurulum:

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | bash -s -- --devin --project
```

Kurulum kontrolü:

```bash
find ~/.codeium/windsurf/global_workflows -maxdepth 1 -type f | sort
```

Beklenen workflow dosyaları:

```text
analyze.md
execute.md
investigate.md
jira.md
repo.md
review.md
dbt-test-monitor.md
```

---

## 4. Optional: dbconnect Kurulumu

Bu bölüm opsiyoneldir. Snowflake, PostgreSQL ve MongoDB bağlantılarını tek bir lokal komut üzerinden yönetmek isteyen kullanıcılar için `dbconnect` helper kurulumu sağlar.

`dbconnect` kurulumu gerçek DB/server şifresi, SSH key, token veya connection string içermez. Kurulum script’i sadece lokal dosya yapısını oluşturur.

Kurulum:

```bash
bash scripts/install-dbconnect.sh
```

Kurulum sonrası lokal config dosyası oluşturulur:

```text
~/.config/dbconnect/connections.toml
```

Bu dosya kullanıcı tarafından manuel doldurulmalıdır:

```bash
vi ~/.config/dbconnect/connections.toml
```

Fish function dosyası şu path’e kopyalanır:

```text
~/.config/fish/functions/dbconnect.fish
```

Örnek test komutları:

```bash
dbconnect -c <connection_name> -q 'SELECT 1'
dbconnect -c <connection_name> -q 'db.runCommand({ping:1})'
```

Güvenlik notları:

```text
- Gerçek DB/server şifreleri repository içinde tutulmaz.
- connections.toml sadece kullanıcının lokal ortamında oluşturulur.
- connections.toml dosya izni chmod 600 olarak ayarlanır.
- SSH private key, DB password, token veya connection string AI prompt’una yazılmamalıdır.
- Prod connection kullanılacaksa kullanıcıdan açık onay alınmalıdır.
```

---

## 5. Atlassian / Etiyawiki MCP Bağlantısı

Jira task içeriklerinin AI tarafından okunabilmesi için Atlassian/Etiyawiki MCP bağlantısı yapılmalıdır.

---

### 5.1 OpenCode MCP Config Oluşturma

Önce config klasörü oluşturulur:

```bash
mkdir -p ~/.config/opencode
```

Bash kullanıyorsanız:

```bash
cat > ~/.config/opencode/opencode.json <<'EOF'
{
  "mcp": {
    "etiyawiki": {
      "type": "remote",
      "url": "https://mcp.atlassian.com/v1/mcp"
    }
  }
}
EOF
```

Fish shell kullanıyorsanız:

```fish
printf '%s\n' \
'{' \
'  "mcp": {' \
'    "etiyawiki": {' \
'      "type": "remote",' \
'      "url": "https://mcp.atlassian.com/v1/mcp"' \
'    }' \
'  }' \
'}' > ~/.config/opencode/opencode.json
```

Kontrol:

```bash
cat ~/.config/opencode/opencode.json
```

Beklenen çıktı:

```json
{
  "mcp": {
    "etiyawiki": {
      "type": "remote",
      "url": "https://mcp.atlassian.com/v1/mcp"
    }
  }
}
```

---

### 5.2 MCP OAuth Authentication

Auth başlatılır:

```bash
opencode mcp auth etiyawiki
```

Terminal size bir URL verir.

Yapılacaklar:

1. URL’yi browser’da açın.
2. Atlassian hesabınızla giriş yapın.
3. Allow / İzin ver seçeneği ile devam edin.
4. Browser callback sayfasında hata görürseniz bu normal olabilir.
5. Browser adres çubuğundaki callback URL’yi komple kopyalayın.
6. İlk terminalde `opencode mcp auth etiyawiki` komutu açık kalmalıdır.
7. İkinci bir terminal açın.
8. Callback URL’yi curl ile çağırın:

```bash
curl "CALLBACK_URL"
```

Örnek:

```bash
curl "http://127.0.0.1:19876/mcp/oauth/callback?code=xxxxx&state=yyyyy"
```

Önemli notlar:

```text
- İlk terminalde auth komutu açık kalmalıdır.
- Callback URL browser adres çubuğundan kopyalanmalıdır.
- URL tek satır olmalıdır.
- URL çift tırnak içinde çalıştırılmalıdır.
```

Eğer auth komutu kapanırsa callback server kapanır ve şu hata alınır:

```text
curl: (7) Failed to connect to 127.0.0.1 port XXXXX
```

Bu durumda auth komutu tekrar başlatılmalı ve callback işlemi auth açıkken yapılmalıdır.

MCP bağlantı kontrolü:

```bash
opencode mcp list
```

---

## 6. İlk Kullanım Testi

Darwin için:

```bash
cd ~/codes/darwin
opencode
```

OpenCode içinde:

```text
/analyze DWHOPRS-123
```

Gerçek bir Jira task numarası ile test edin.

Task içeriği okunup Türkçe özetleniyorsa MCP ve command kurulumu başarılıdır.

---

## 7. Commands / Skills

### Commands

| Command             | Açıklama                                                              |
| ------------------- | --------------------------------------------------------------------- |
| `/analyze`          | Jira task’ını analiz eder, sınıflandırır ve sonraki workflow’u önerir |
| `/investigate`      | DWH/ETL/SQL veri inceleme ve kök neden analizi yapar                  |
| `/execute`          | Çoklu-agent workflow ile Jira task’ını uçtan uca yönetir              |
| `/repo`             | Repo/path/branch çözümleme ve kod değişikliği workflow’unu yönetir    |
| `/jira`             | Jira comment, worklog, status ve closure işlemleri için kullanılır    |
| `/review`           | Yapılan işin final kontrolünü yapar                                   |
| `/dbt-test-monitor` | dbt test ve freshness warn/fail sonuçlarını analiz eder               |

---

### Skills

| Skill           | Açıklama                                                                                                          |
| --------------- | ----------------------------------------------------------------------------------------------------------------- |
| `data-engineer` | Data Engineering, DWH OPS, ETL hata analizi, Jira task analizi, repo güvenliği ve veri investigation metodolojisi |
| `caveman`       | Ultra-compressed caveman communication mode                                                                       |
| `context7`      | Güncel kütüphane dökümantasyonu için Context7 entegrasyonu                                                        |

---

## 8. Kullanım Örnekleri

### Jira Task Analizi

```text
/analyze DWHOPRS-123
```

### Data / ETL Problem İnceleme

```text
/investigate DWHOPRS-123
```

### Kod Değişikliği Gereken İşler

```text
/repo DWHOPRS-123
```

### Jira Execution Log / Worklog / Status

```text
/jira DWHOPRS-123
```

### Final Kontrol

```text
/review DWHOPRS-123
```

### Uçtan Uca Workflow

```text
/execute DWHOPRS-123
```

### dbt Test / Freshness Monitoring

```text
/dbt-test-monitor
/dbt-test-monitor --last-24h
/dbt-test-monitor --last-7d --severity fail
/dbt-test-monitor --table dwf_sales
```

---

## 9. Önerilen Workflow

Genel Jira task akışı:

```text
/analyze TASK-ID
    ↓
/investigate TASK-ID
    ↓
/repo TASK-ID          → kod değişikliği gerekiyorsa
    ↓
/review TASK-ID        → final kontrol
    ↓
/jira TASK-ID          → execution log / worklog / status
```

dbt test/freshness monitoring akışı:

```text
/dbt-test-monitor
    ↓
warn/fail sonuçlarını sınıflandır
    ↓
freshness ihlallerini kritik işaretle
    ↓
güvenli SELECT kontrolleri öner
    ↓
Jira task/comment taslağı üret
```

---

## 10. Güvenlik Kuralları

Bu paket aşağıdaki güvenlik kurallarına göre tasarlanmıştır:

```text
- Otomatik Jira task açmaz.
- Otomatik Jira status değiştirmez.
- Otomatik worklog girmez.
- Otomatik ETL rerun yapmaz.
- Otomatik dbt run/test çalıştırmaz.
- Jenkins/Dagster/cron/schedule değiştirmez.
- DB write işlemi yapmaz.
- INSERT/UPDATE/DELETE/MERGE/TRUNCATE/DROP işlemleri önermez.
- Sadece güvenli SELECT SQL kontrolleri önerir.
- Kullanıcı onayı olmadan repo değişikliği, commit veya push yapmamalıdır.
- Root cause kanıtlanmamışsa hipotez olarak ifade edilir.
```

---

## 11. Proje Reposunu Güncelleme

Bitbucket reposu güncellendikçe lokal repo güncellenmelidir.

Örnek:

```bash
cd ~/codes/darwin
git pull
```

Fizz:

```bash
cd ~/codes/fizz
git pull
```

Eğer şu hata alınırsa:

```text
fatal: not a git repository
```

ilgili klasör gerçek git repo değildir. Klasör silinip yeniden clone edilmelidir.

---

## 12. Sorun Giderme

### Permission denied publickey

Hata:

```text
Permission denied (publickey)
```

Çözüm:

```text
- SSH key oluşturulmalı.
- Public key Bitbucket SSH Keys alanına eklenmeli.
- Kullanıcının ilgili repo yetkisi kontrol edilmeli.
```

Test:

```bash
ssh -T git@bitbucket2.etiya.com
```

---

### ssh connecting ekranında kalıyor

Bu genelde network/VPN/port erişimi problemidir.

Kontrol:

```bash
ssh -vT git@bitbucket2.etiya.com
```

Port kontrolü:

```bash
nc -vz bitbucket2.etiya.com 22
```

`nc` yoksa:

```bash
sudo apt install -y netcat-openbsd
```

---

### MCP auth sonrası curl bağlantı hatası

Hata:

```text
curl: (7) Failed to connect to 127.0.0.1 port XXXXX
```

Sebep:

```text
opencode mcp auth etiyawiki komutu kapanmıştır.
Callback server artık çalışmıyordur.
```

Çözüm:

```text
1. opencode mcp auth etiyawiki komutunu tekrar başlat.
2. İlk terminali açık bırak.
3. Browser login sonrası callback URL’yi kopyala.
4. İkinci terminalde curl "CALLBACK_URL" çalıştır.
```

---

## 13. Repository Yapısı

`components/commands` klasörü OpenCode command dosyalarını, `components/devin-workflows` klasörü ise aynı workflow’ların Windsurf / Devin CLI uyumlu versiyonlarını içerir.

```text
ddata-engineer/
├── .github/workflows/security.yml
├── registry.json
├── install.sh
├── dbconnect/
│   └── dbconnect.fish
├── scripts/
│   └── install-dbconnect.sh
├── components/
│   ├── commands/
│   │   ├── analyze.md
│   │   ├── execute.md
│   │   ├── investigate.md
│   │   ├── jira.md
│   │   ├── repo.md
│   │   ├── review.md
│   │   └── dbt-test-monitor.md
│   ├── commands_legacy/
│   ├── devin-workflows/
│   │   ├── analyze.md
│   │   ├── execute.md
│   │   ├── investigate.md
│   │   ├── jira.md
│   │   ├── repo.md
│   │   ├── review.md
│   │   └── dbt-test-monitor.md
│   └── skills/
│       ├── data-engineer/
│       ├── caveman/
│       └── context7/
├── LICENSE
└── README.md
```

---

## 14. Legacy Commands

Eski command’ler `commands_legacy/` altında arşivlenmiştir.

Örnek:

```text
commit
test
typecheck
data_investigation
jira_action
jira_review
project_resolver
repo_apply
```

---

## License

MIT
