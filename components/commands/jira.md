---
description: Safe Jira operations for comments, transitions, worklog and closure
---
Handle safe Jira operations for Etiyawiki tasks.

Use the etiyawiki MCP server to work on issue {{args}}.

Use the Data Engineer skill rules and package workflow.

## Purpose

This command handles Jira-side operations for Data Engineering, DWH OPS, Development, and Operations teams.

It supports:

- reading Jira task status
- adding professional comments
- adding investigation logs
- adding execution logs
- transitioning status
- adding worklog
- preparing Test / Resolved notes
- final Jira-side review

This command must never perform Jira write actions without explicit user approval.

---

## Supported Jira Actions

Use this command for:

- Start work comment
- Investigation log comment
- Execution log comment
- Customer/business explanation comment
- Technical analysis summary comment
- Worklog entry
- Status transition to In Progress
- Status transition to Test
- Status transition to Resolved
- Closure note
- Manual follow-up note

---

## Phase 1 — Read and Summarize Jira Task

Read the Etiyawiki Jira issue and extract:

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

---

## Phase 2 — Decide Jira Action Type

Determine what the user wants:

- add comment
- add investigation log
- add execution log
- transition status
- add worklog
- close / move to Test / move to Resolved
- review Jira readiness
- prepare comment text only

If the user has not clearly requested a write action:

- do not write anything
- prepare suggested text only
- ask for approval before adding it to Jira

---

## Phase 3 — Comment Rules

Before adding any Jira comment, show the comment text and ask:

"Bu yorumu Jira'ya eklememi ister misin? (yes/no)"

Comment style must be:

- Turkish unless user requests English
- professional
- concise
- factual
- clear about confirmed findings vs hypotheses
- clear about missing information
- suitable for Jira history

For investigation comments, include:

- problem summary
- affected object/table/job
- suspected layer
- key findings
- hypotheses
- suggested validation checks
- missing information
- next owner/team if relevant

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
- unnecessary long SQL unless needed
- unverified root cause as confirmed fact

---

## Phase 4 — Status Transition Rules

Before any status transition:

1. Read current status.
2. Check available transitions.
3. Explain target status.
4. Ask for explicit approval.

Ask:

"Task statüsünü `<target_status>` olarak değiştirmemi ister misin? (yes/no)"

Only transition if the user explicitly approves.

Do not transition if:

- transition is not available
- permission is missing
- issue is terminal and user did not confirm exceptional action
- investigation is incomplete
- required review is missing
- user has not approved

Recommended status behavior:

- Move to In Progress only when work is actually starting.
- Move to Test only when change/investigation is completed and ready for validation.
- Move to Resolved only when the user explicitly confirms resolution.
- Never close automatically.

---

## Phase 5 — Worklog Rules

Before adding worklog, ask:

"Bu task için kaç saat worklog girmemi istersin? Örn: 30m, 1h, 2h. Eğer log girmek istemiyorsan 'skip' yazabilirsin."

If user provides duration:

- add the worklog using that duration
- add a short note if needed
- report that worklog was added

If user says `skip`:

- do not add worklog

If duration is unclear:

- ask for clarification
- do not guess

Never add worklog without explicit duration.

---

## Phase 6 — Final Jira Review

Before moving to Test or Resolved, review:

- Was the requested work actually completed?
- Was repo/code change completed, if relevant?
- Was commit/push completed, if relevant?
- Was investigation result evidence-based?
- Are missing information and assumptions clearly stated?
- Was Jira log added, if requested?
- Is worklog needed?
- Is the next status appropriate?

If something is missing, say clearly:

"Bu task henüz Test/Resolved için hazır görünmüyor."

Then list what is missing.

---

## Safety Rules

- Always respond in Turkish.
- Use only Etiyawiki task content and user-provided context.
- Do not modify code.
- Do not run Git commands.
- Do not execute SQL.
- Do not run DB write operations.
- Do not rerun ETL.
- Do not add comments without approval.
- Do not transition status without approval.
- Do not add worklog without explicit duration.
- Do not close the issue automatically.
- Do not claim task is completed unless verified.
- If permission or assignment prevents action, explain the issue.
- If issue is Cancelled / Closed / Resolved / Done, stop and ask.

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

For final Jira readiness review:

1. Yapılan İşlem
2. Jira Log Durumu
3. Worklog Durumu
4. Statü Geçişi Uygun mu?
5. Eksik / Riskli Noktalar
6. Önerilen Sonraki Statü
7. Onay Sorusu