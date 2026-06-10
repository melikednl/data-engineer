# Data Engineer — Opencode Pack

Etiyawiki Jira işlerini çözmek, analiz yapmak ve problemleri gidermek için opencode command ve skill paketi.

## Kurulum

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | sh
```

Tüm projelerde kullanmak için (global):

```bash
curl -fsSL https://raw.githubusercontent.com/melikednl/data-engineer/main/install.sh | sh -s -- --global
```

### OCX ile (önerilen, update desteği)

```bash
curl -fsSL https://ocx.kdco.dev/install.sh | sh
ocx registry add data-engineer https://raw.githubusercontent.com/melikednl/data-engineer/main/registry.json
ocx add data-engineer/commands
ocx add data-engineer/skills
```

### Tek tek komut yükleme

```bash
ocx add data-engineer/commands-analyze
ocx add data-engineer/commands-investigate
ocx add data-engineer/commands-jira
```

## Commands (6)

| Command | Subtask | Description |
|---------|---------|-------------|
| `/analyze` | — | Jira task'ini analiz et, sınıflandır, detayları çıkar |
| `/execute` | ✅ | Çoklu-agent workflow ile Jira task'ini uçtan uca çöz |
| `/investigate` | ✅ | DWH/ETL/SQL veri inceleme ve kök neden analizi |
| `/jira` | — | Tek elden Jira işlemleri: action + review + closure |
| `/repo` | — | Proje/repo çözümle + kod değişikliklerini uygula |
| `/review` | ✅ | Code değişikliklerini review et |

## Skills (2)

| Skill | Description |
|-------|-------------|
| `caveman` | Ultra-compressed caveman communication mode |
| `context7` | Güncel kütüphane dökümantasyonu (Context7 API) |

## Kullanım

```bash
opencode
```

Ardından TUI'de:

```
/analyze PROJ-123
/execute PROJ-789
/investigate PROJ-456
/jira PROJ-321
/repo PROJ-654
```

## Workflow

```
/analyze PROJ-123    → Task'i analiz et. Türüne göre yönlendir:
  ├─ repo işi varsa → /repo        → Branch aç, değişiklik yap, commit
  ├─ veri sorunu    → /investigate → Kök neden analizi, SQL üret
  ├─ tümünü birden  → /execute     → Otomatik full workflow
  └─ tamamlandı     → /jira        → Log, transition, worklog, closure
/review              → Code kalite kontrol
```

## Sub-agent (subtask)

Uzun süreli işlemler (`/execute`, `/investigate`, `/review`) sub-agent'da çalışır. Ana kontekst şişmez, her işlem temiz ortamda yürütülür.

## Proje Yapısı

```
data-engineer/
├── .github/workflows/security.yml   # CI: truffleHog, markdown lint, shellcheck, registry validation
├── registry.json                    # OCX registry definition
├── install.sh                       # Single-command installer
├── components/
│   ├── commands/                    # 6 core data-engineer commands
│   ├── commands_legacy/             # Legacy commands archive
│   └── skills/                      # SKILL.md files
├── LICENSE
└── README.md
```

## Legacy

Eski command'ler (`commit`, `test`, `typecheck`, `data_investigation`, `jira_action`, `jira_review`, `project_resolver`, `repo_apply`) `commands_legacy/` altında arşivlendi:

```bash
ocx add data-engineer/commands-legacy
```

## License

MIT
