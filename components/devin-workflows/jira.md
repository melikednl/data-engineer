---
name: jira
description: Safe Jira operations for comments, transitions, worklog, closure and task creation
---

Handle safe Jira operations for Etiyawiki/Jira tasks.

Use the configured Etiyawiki/Jira MCP server to work on issue `{{args}}`.

Follow the Data Engineer skill rules, especially:

- Sensitive Data Handling
- Jira / Rovo MCP Data Safety
- Jira Workflow
- Core Safety Rules

## Purpose

This command handles Jira-side operations for Data Engineering, DWH OPS, Development, and Operations teams.

It supports:

- reading Jira task status
- adding professional comments
- adding investigation logs
- adding execution logs
- adding customer/business explanation comments
- adding technical analysis summary comments
- adding worklog
- transitioning status
- preparing In Acceptance / Closed notes
- final Jira-side review
- creating new Jira tasks after explicit approval
- creating internal Etiyawiki/Jira tasks from Fizz FMS customer tickets

This command must never perform Jira write actions without explicit user approval.

This command must not expose sensitive customer identifiers, personal data, credentials, tokens, private keys, SSH keys, or connection strings.

---

## Current Jira Workflow

Follow the current project workflow:

```text
Open → In Progress → In Acceptance → Closed
```

Status meaning:

- `Open` means the task is created but work has not started yet.
- `In Progress` means the task is actively being analyzed, developed, or investigated.
- `In Acceptance` means the work is completed and waiting for user, customer, PO, or business acceptance.
- `Closed` means the task is completed and closed.
- `Blocked` means progress is blocked by a dependency, missing information, access issue, approval, or external team.
- `Cancelled` means the task is cancelled and should not continue unless exceptional action is required.

---

## Supported Jira Actions

Use this command for:

- Start work comment
- Investigation log comment
- Execution log comment
- Customer/business explanation comment
- Technical analysis summary comment
- Worklog entry
- Status transition to `In Progress`
- Status transition to `In Acceptance`
- Status transition to `Closed`
- Closure note
- Manual follow-up note
- Jira readiness review
- Comment draft preparation
- New task creation
- Internal Etiyawiki task creation from Fizz FMS ticket

---

## Fizz FMS Project Reference

Fizz customer tickets are located under the Jira project key:

```text
FMS
```

Use the FMS project key when searching or reading Fizz customer tickets.

Default FMS JQL:

```sql
project = "FMS"
ORDER BY resolved DESC, created DESC
```

For the Fizz customer tickets usually handled by the team, the filtered FMS list view may use a reporter-based JQL filter:

```sql
project = "FMS"
AND reporter IN (<configured reporter account ids>)
ORDER BY resolved DESC, created DESC
```

Do not rely only on a browser URL.

Prefer the Jira project key `FMS` and JQL search when reading Fizz tickets through MCP.

If the user provides an FMS ticket ID such as `FMS-12345`, read that exact issue from the `FMS` project.

If the user provides only a browser URL, extract the project key, issue key, or JQL from the URL when possible.

---

## Task Creation Safety Rules

This command may create a new Jira task only after the target location and content are confirmed.

Before creating any new task, always confirm:

- target Jira site / workspace
- target project or team
- issue type
- summary
- description
- priority, if needed
- assignee, if needed
- labels, if needed
- linked source ticket, if relevant
- parent / epic, if relevant

Do not create a task if the target project, team, or board is missing or ambiguous.

Never assume the target team.

Never assume the target project.

Never create a task in a default project unless the user explicitly confirms it.

If the user says “task aç”, “yeni task oluştur”, “Etiyawiki’de task aç”, or similar, ask:

```text
Bu task’ı hangi team / project alanına açmamı istersin?
Örn: DWH OPS, Data Engineering, Development, Fizz, Darwin, Maya veya ilgili Jira project key.
```

If multiple projects or teams are possible, list the uncertainty and ask the user to choose.

---

## Fizz FMS Ticket to Internal Etiyawiki Task Workflow

When the user provides a Fizz FMS ticket ID and asks to create an internal Etiyawiki/Jira task:

1. Read the FMS ticket using the configured Etiyawiki/Jira MCP server.
2. Extract the customer/business issue.
3. Mask sensitive values in the chat output.
4. Prepare a Turkish internal task draft.
5. Ask the user which internal team / project the new task should be opened under.
6. Ask the user to confirm the final task content.
7. Create the new task only after explicit approval.
8. Link or reference the source FMS ticket when possible.
9. Report the created task key and URL if available.

Do not create the internal task directly inside the FMS project unless the user explicitly asks for that.

The internal task draft should include:

- source FMS ticket ID
- customer issue summary
- business impact
- affected product / service / report / table, if available
- requested investigation or action
- technical clues from the FMS ticket
- expected output
- acceptance criteria
- missing information
- suggested responsible team
- source ticket reference

Sensitive customer identifiers must be masked in the chat output and in generated task descriptions unless exact values are strictly required for operational investigation.

If exact customer/account identifiers are required, prefer referencing the original FMS ticket instead of repeating the full values.

---

## Phase 1 — Read and Summarize Jira Task

Read the Etiyawiki/Jira issue and extract:

- Jira ID
- summary
- current status
- assignee
- reporter
- priority
- task type
- latest relevant comments, if available
- available transitions, if available
- whether task looks terminal or active

Terminal statuses include:

- Cancelled
- Closed
- Resolved
- Done

If the issue is in a terminal status:

- stop
- explain the current status
- ask whether exceptional action is required

Mask sensitive values in the output.

Do not repeat full customer identifiers, emails, phone numbers, account IDs, invoice numbers, credentials, tokens, private keys, SSH keys, or connection strings.

---

## Phase 2 — Decide Jira Action Type

Determine what the user wants:

- add comment
- add investigation log
- add execution log
- transition status
- add worklog
- move to `In Progress`
- move to `In Acceptance`
- move to `Closed`
- prepare closure note
- review Jira readiness
- prepare comment text only
- create new Jira task
- create internal Etiyawiki task from Fizz FMS ticket

If the user has not clearly requested a write action:

- do not write anything
- prepare suggested text only
- ask for approval before adding it to Jira

---

## Phase 3 — Comment Rules

Before adding any Jira comment, show the comment text and ask:

```text
Bu yorumu Jira'ya eklememi ister misin? (yes/no)
```

Comment style must be:

- Turkish unless user requests English
- professional
- concise
- factual
- clear about confirmed findings vs hypotheses
- clear about missing information
- suitable for Jira history
- masked for sensitive values

For investigation comments, include:

- problem summary
- affected object / table / job
- suspected layer
- key findings
- hypotheses
- suggested validation checks
- missing information
- next owner / team if relevant

For execution comments, include:

- what was changed
- files changed, if relevant
- branch, if relevant
- commit hash, if available
- validation performed
- approvals received

Do not include:

- internal reasoning
- debug logs
- secrets
- DB credentials
- connection strings
- private keys
- SSH keys
- unmasked customer identifiers
- unnecessary long SQL unless needed
- unverified root cause as confirmed fact

If exact identifiers are required for user-side checking, refer the user to the original Jira task instead of exposing the values in chat.

---

## Phase 4 — Status Transition Rules

Before any status transition:

1. Read current status.
2. Check available transitions.
3. Explain target status.
4. Ask for explicit approval.

Ask:

```text
Task statüsünü `<target_status>` olarak değiştirmemi ister misin? (yes/no)
```

Only transition if the user explicitly approves.

Do not transition if:

- transition is not available
- permission is missing
- issue is terminal and user did not confirm exceptional action
- investigation is incomplete
- required review is missing
- user has not approved

Recommended status behavior:

- Move to `In Progress` only when work is actually starting and the user approves.
- Move to `In Acceptance` only when the work is completed, verified, summarized, and the user approves.
- Move to `Closed` only after explicit user approval and acceptance is confirmed.
- Never close automatically.
- If the issue is `Blocked`, summarize the blocker and ask the user before transitioning to `Blocked`.
- If the issue is `Cancelled`, `Closed`, `Resolved`, or `Done`, stop and ask whether exceptional action is required.

---

## Phase 5 — Worklog Rules

Before adding worklog, ask:

```text
Bu task için kaç saat worklog girmemi istersin? Örn: 30m, 1h, 2h. Eğer log girmek istemiyorsan 'skip' yazabilirsin.
```

If the user provides duration:

- add the worklog using that duration
- add a short note only if needed and approved
- report that worklog was added

If the user says `skip`:

- do not add worklog

If duration is unclear:

- ask for clarification
- do not guess

Never add worklog without explicit duration.

---

## Phase 6 — New Task Creation Rules

Before creating a new Jira task:

1. Understand the requested task.
2. Ask for target team / project if not clearly provided.
3. Prepare the task draft.
4. Show the draft to the user.
5. Ask for explicit approval.
6. Create the task only after approval.

Ask:

```text
Bu task’ı hangi team / project alanına açmamı istersin?
```

Then prepare a draft with:

- Summary
- Description
- Issue type
- Priority, if available
- Assignee, if available
- Labels, if needed
- Source ticket reference, if available
- Acceptance criteria

Before creating, ask:

```text
Bu task’ı yukarıdaki içerikle Jira’da oluşturmamı ister misin? (yes/no)
```

Do not create the task unless the user explicitly approves.

If the task is created successfully:

- report the new Jira key
- report the new Jira URL, if available
- suggest whether a source ticket comment/link should be added

Do not add a comment to the source ticket unless the user approves.

---

## Phase 7 — FMS to Internal Task Draft Format

When creating an internal task from a Fizz FMS ticket, use this Turkish structure:

```text
Başlık:
[FMS Ticket ID] - <Kısa problem özeti>

Açıklama:
Fizz FMS tarafında iletilen müşteri/talep kapsamında aşağıdaki konu için inceleme gerekmektedir.

Kaynak Ticket:
<FMS Ticket ID>

Problem Özeti:
<Maskelenmiş ve Türkçe özet>

Etkilenen Alan:
<Ürün / servis / rapor / tablo / süreç bilgisi varsa>

Teknik İpuçları:
<FMS ticket içindeki hata mesajı, tarih, fatura, kullanım, paket, data, servis, tablo veya sistem bilgileri>

Beklenen Aksiyon:
<Kontrol / analiz / BSS yönlendirme / DWH inceleme / data correction / müşteri dönüşü için bilgi>

Kabul Kriteri:
- FMS ticket içeriği incelenmelidir.
- İlgili sistem / tablo / süreç kontrolleri yapılmalıdır.
- Kök neden veya bulgu Jira’ya log olarak eklenmelidir.
- Gerekirse ilgili ekibe yönlendirme yapılmalıdır.
- Hassas müşteri bilgileri yorumlarda maskelenmelidir.

Eksik Bilgiler:
<Belirtilmemiş veya doğrulanamayan bilgiler>

Önerilen Team:
<Kullanıcıdan alınan veya analizle önerilen team>
```

If the target team/project is unknown, do not create the task. Ask the user to specify it.

---

## Phase 8 — Final Jira Review

Before moving to `In Acceptance` or `Closed`, review:

- Was the requested work actually completed?
- Was repo/code change completed, if relevant?
- Was commit/push completed, if relevant?
- Was investigation result evidence-based?
- Are missing information and assumptions clearly stated?
- Are sensitive values masked?
- Was Jira log added, if requested?
- Is worklog needed?
- Is the next status appropriate?

If something is missing, say clearly:

```text
Bu task henüz In Acceptance / Closed için hazır görünmüyor.
```

Then list what is missing.

---

## Safety Rules

Follow the centralized Data Engineer skill safety rules.

This command must especially enforce:

- Always respond in Turkish.
- Use only Etiyawiki/Jira task content and user-provided context.
- Mask sensitive values in responses, Jira comment drafts, and task descriptions.
- Ask for target team / project before creating a new Jira task.
- Do not create a task in an assumed project.
- Do not create a task without approval.
- Do not modify code.
- Do not run Git commands.
- Do not execute SQL.
- Do not run DB write operations.
- Do not use `dbconnect`, `snow`, `psql`, or `mongosh`.
- Do not rerun ETL.
- Do not update control tables.
- Do not add comments without approval.
- Do not transition status without approval.
- Do not add worklog without explicit duration.
- Do not close the issue automatically.
- Do not claim task is completed unless verified.
- If permission or assignment prevents action, explain the issue.
- If issue is `Cancelled`, `Closed`, `Resolved`, or `Done`, stop and ask whether exceptional action is required.
- Never expose credentials, tokens, private keys, SSH keys, passwords, DB connection strings, or full customer identifiers.

---

## Output Format

For Jira action review:

1. Jira Özeti
2. Mevcut Statü
3. İstenen Jira Aksiyonu
4. Hazırlanan Yorum / Log
5. Riskler
6. Eksik Bilgiler
7. Onay Sorusu

For new task creation:

1. Kaynak Bilgi / Ticket
2. Hedef Team / Project
3. Oluşturulacak Task Taslağı
4. Eksik Bilgiler
5. Riskler
6. Onay Sorusu

For FMS to internal task creation:

1. FMS Ticket Özeti
2. Hedef Team / Project
3. Türkçe İç Task Taslağı
4. Maskelenen Hassas Bilgiler
5. Eksik Bilgiler
6. Onay Sorusu

For final Jira readiness review:

1. Yapılan İşlem
2. Jira Log Durumu
3. Worklog Durumu
4. Statü Geçişi Uygun mu?
5. Eksik / Riskli Noktalar
6. Önerilen Sonraki Statü
7. Onay Sorusu
