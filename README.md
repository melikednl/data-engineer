# Data Engineer — Opencode Pack

Etiyawiki Jira işlerini çözmek, analiz yapmak ve problemleri gidermek için opencode command ve skill paketi.

## İçindekiler

### Commands (12)

| Command | Description |
|---------|-------------|
| `/analyze` | Jira task'ini analiz et, sınıflandır, detayları çıkar |
| `/commit` | Conventional commit oluştur |
| `/data_investigation` | DWH/ETL/SQL veri inceleme ve kök neden analizi |
| `/execute` | Çoklu-agent workflow ile Jira task'ini uçtan uca çöz |
| `/jira_action` | Jira comment, transition, worklog işlemleri |
| `/jira_review` | Final kalite ve güvenlik review |
| `/project_resolver` | Proje/repo/path/branch bilgilerini çözümle |
| `/repo_apply` | Repository/file/code değişikliklerini uygula |
| `/review` | Code değişikliklerini review et |
| `/solve` | Hızlı Jira task çözümü |
| `/test` | Testleri çalıştır ve hataları düzelt |
| `/typecheck` | Type checker çalıştır ve hataları düzelt |

### Skills (2)

| Skill | Description |
|-------|-------------|
| `caveman` | Ultra-compressed caveman communication mode |
| `context7` | Güncel kütüphane dökümantasyonu (Context7 API) |

## Installation

### Tek komutla (önerilen)

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | sh
```

Tüm projelerde kullanılabilir olması için (global):

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | sh -s -- --global
```

### OCX ile (update desteği)

[OCX](https://github.com/kdcokenny/ocx) kuruluysa:

```bash
ocx registry add data-engineer https://raw.githubusercontent.com/melikednl/data-engineer/main/registry.json
ocx add data-engineer/commands
ocx add data-engineer/skills
```

### Tek tek komut yükleme

OCX ile sadece ihtiyacın olan command'i de yükleyebilirsin:

```bash
ocx add data-engineer/commands-analyze
ocx add data-engineer/commands-data-investigation
```

## Kullanım

```bash
opencode
```

Ardından TUI'de:

```
/analyze PROJ-123
/execute PROJ-456
/data_investigation PROJ-789
/jira_action PROJ-321
```

## Workflow

Tipik bir data engineer akışı:

```
1. /analyze PROJ-123    → Task'i analiz et, türünü belirle
2. /project_resolver     → Repo/path/branch bilgilerini çöz
3. /data_investigation   → Veri problemini derinlemesine incele
4. /execute              ↑ Tümünü otomatik yap
5. /jira_review          → Kalite kontrol
6. /jira_action          → Jira log/transition/worklog
```

## Proje Yapısı

```
data-engineer/
├── registry.json            # OCX registry definition
├── install.sh               # Single-command installer
├── components/
│   ├── commands/            # Command markdown files (12 adet)
│   └── skills/              # Skill SKILL.md files (2 adet)
├── LICENSE
└── README.md
```

## License

MIT
