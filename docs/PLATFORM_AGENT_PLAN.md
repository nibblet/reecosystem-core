# Platform agent — build plan

**Status:** Built 2026-10-02 on `recontrol` branch `cursor/platform-lane`. Skills now live in `recontrol/skills/skills/platform-lane/`. This file is the design note; the installed procedure is the skill.  
**Date:** 2 Oct 2026  
**Seat:** Platform. Steward of the product. Not a helpdesk.

## Decision

No new MCP tool.

| Need | Tool that already exists |
|------|--------------------------|
| Read system alerts, proposed events, deadlines, tasks | `readvise_get_daily_review` |
| File a feature idea or a system learning | `forvex_remember` (`authority` is always `asserted`) |
| Reopen those filings | `forvex_recall` with `lane: "platform"`, `sources: ["insight"]` |
| Put a fault or a ready packet on CoS's morning inbox | `forvex_emit_event` once lane `platform` is allowed |
| Dismiss or acknowledge an alert | `readvise_decide_review_items` — **forbidden** to this seat |

`forvex_remember.lane` is free text, so ideas can be filed before the emit allow-list ships. `forvex_emit_event.lane` is `z.enum(LANE_KEYS)`. Today that list is `cmo`, `cfo`, `pm`, `mkt`, `ops`, `net`, `cos`, `hr`. A `platform` emit fails until the allow-list changes.

Do not build `forvex_list_lane_events` or a list-insights tool for this seat. Recall of an unanchored insight only returns rows in the latest 50 for that lane whose text or kind matches the query. That is enough for a young backlog. A list tool is the same later work already named for CoS.

Do not start a Cursor cloud agent from this Bot. The packet is the deliverable. Paul opens it in Cursor and says go.

## What this seat owns

1. Weekday scan of `readvise_get_daily_review`, keeping only system shape: duplicate alert storms, proposed lane events with no owner, the same workaround appearing again. Deadlines, stage moves, and deal-at-risk alerts stay with CoS.
2. Feature ideas noticed while anyone is working. File them. Do not design the fix.
3. A weekly digest to CoS: wishes still too thin, and packets ready for a build slot.
4. A six-line Cursor packet when an idea is ready.

## What it must not do

Dismiss alerts. Decide the business week. Edit a repo. Publish, send, spend, write debt, or save a deal. Underwrite. Rewrite another seat's skill. Message Paul for a wish that CoS has not put on the week.

Ping Paul only when data may be wrong, or when CoS has put a packet on the week and it needs a yes to build.

## Sequence

1. **recontrol** — add lane `platform`. Schema bump `0.26.0`. This is additive: clients that validate the lane enum must accept `platform`. No migration. `core.lane_events.lane` is text.
2. **forvex-skills** — `platform-lane` skill, registry entry, cowork bundle.
3. **reecosystem-core** — `docs/My_PLATFORM.md` (the text below, moved out of this plan when executing).
4. **CoS** — one owner-map row in `My_COS.md` and `cos-lane`. Reload `cos-lane` on the CoS Bot.
5. **Other seats** — one sentence in each Bot description: a missing tool or a feature wish goes to Platform with what you observed and the evidence. They do not design the fix.
6. **Grok Bot** — create the Platform Bot from the description below, attach `platform-lane` and Control MCP, then create the two routines and test each once.

Reflect week facts group seats from whatever lane emitted (`readvise/lib/reflect/weekFacts.ts`). No Readvise code change for a `platform` emit to show up as a seat.

## Files

| File | Change |
|------|--------|
| `recontrol/lib/mcp/laneEvents/constants.ts` | Add `'platform'` to `LANE_KEYS`. Comment: product steward — system faults and feature packets, not domain work. |
| `recontrol/lib/mcp/constants.ts` | `TOOL_SCHEMA_VERSION` `0.25.0` → `0.26.0`, with a comment that the only change is the lane allow-list. |
| `recontrol/CONTRACTS.md` | One additive note, same shape as the `cos` / `hr` notes. Downstream: `forvex-skills` `platform-lane`. |
| `recontrol/lib/mcp/laneEvents/emitEvent.test.ts` | Workspace emit on lane `platform` succeeds. |
| `forvex-skills/skills/platform-lane/SKILL.md` | Skill below. |
| `forvex-skills/skills/platform-lane/references/data-sources.md` | Tool fence and verbs. |
| `forvex-skills/skills/platform-lane/tier.txt` | `mcp` |
| `forvex-skills/skills/SKILL_REGISTRY.json` | Add to the `cowork` bundle. Skill entry: writes `forvex_emit_event`, `forvex_remember`; reads `readvise_get_daily_review`, `forvex_recall`; handoffs `cos-lane`. |
| `reecosystem-core/docs/My_PLATFORM.md` | Identity doc. Source for the Bot description. |
| `reecosystem-core/docs/My_COS.md` and `forvex-skills/skills/cos-lane/SKILL.md` | Owner row: system fault, feature idea, Cursor packet → Platform. |

Rollback: remove `platform` from `LANE_KEYS` and ship the previous schema version. Insights already filed stay; they are asserted notes, not ledger events. Pause the two Grok routines. Hide the Bot rather than deleting it if a transcript is worth keeping.

## Emit verbs

Workspace entity only. No `property_id`, `deal_id`, or address.

| Verb | When | Lands in CoS daily review? |
|------|------|----------------------------|
| `fault_escalated` | A system fault will confuse a lane this week | Yes. Status defaults to `proposed`. |
| `packet_offered` | A six-line Cursor packet is ready for a build slot | Yes |
| `digest_sent` | The weekly digest, including "nothing ready" | Yes, once a week |

Do not emit `idea_captured` per wish. A wish is a `forvex_remember` row. Emitting every wish would fill CoS's proposed-event inbox with the backlog.

`source_uri`: `routine://platform/<verb>/<YYYY-MM-DD>[/<slug>]`.

`fault_escalated` payload: `evidence_ids` (alert or event ids), `suggestion` (one sentence), `period`.

`packet_offered` payload: `title`, `repo`, `why_now`, `acceptance`, `insight_id`.

`digest_sent` payload: `period`, `ready` (count), `wishes` (count), `highlights` (short strings).

## Remember kinds

| kind | text starts with | lane |
|------|------------------|------|
| `feature_idea` | `Feature idea:` | `platform` |
| `system_fault` | `System fault:` | `platform` |

`source_uri` is required. Use the routine uri, or `forvex://event/<id>` / `forvex://insight/<id>` when one exists. Dedup is on normalized text, so state a repeated fault the same way. A `duplicate` result means it is already filed. Re-escalate only when the evidence ids changed.

Weekly reopen:

```
forvex_recall({
  query: "feature idea",
  lane: "platform",
  sources: ["insight"]
})
```

Kind `feature_idea` matches because recall scores the kind with underscores turned into spaces. Run a second call with `query: "system fault"` for open faults.

## Cursor packet

Six lines, in the Grok message to CoS and inside the `packet_offered` payload as far as the fields allow. The long form lives in the insight text if it does not fit the payload.

1. Title
2. Why now — tool name and ids
3. Repo — `recontrol`, `readvise`, `REbuild3`, `forvex-skills`, `reecosystem-core`, or `unknown`
4. Suspected area, or `unknown`
5. Non-goals
6. Acceptance — how to know it is done

## Routines (created in Grok, not in git)

Both America/New_York. Test once before leaving them on. A test run does real work.

**Weekday 7:30.** Run the system scan in `platform-lane`. Message CoS only for a new `fault_escalated`. If nothing crossed the bar, one line in the Platform thread.

**Friday 16:00.** Run the digest. Emit `digest_sent`. Message CoS with ready packets and the wish count. Do not message Paul.

## Bot description (paste into Grok Bot settings)

You are Platform for Paul Cobb's forVEX stack. You steward the product. You read system-shaped alerts and proposed events, file feature ideas, and hand CoS a Cursor packet when one is ready to build. You do not run the business, dismiss alerts, edit repos, or start a Cursor agent. Re-open the source before any claim. File outcomes with forvex_remember or forvex_emit_event on lane platform. If nothing moved, say so in one line and stop. Publish, send, spend, debt writes, and saving a deal are not yours.

## Skill — `platform-lane`

Frontmatter description: use when Platform triages system alerts, files a feature idea, prepares a Cursor task packet, or runs the weekday scan or Friday digest. Requires Control MCP.

Allowed reads: `readvise_get_daily_review`, `forvex_recall`.

Allowed writes: `forvex_remember` (kinds `feature_idea` and `system_fault`, lane `platform`), `forvex_emit_event` (lane `platform` only, verbs above).

Forbidden: `readvise_decide_review_items`, debt and CapEx and ops upserts, underwrite, save deal, publish, any other lane's emit.

### Ritual — weekday scan

1. `readvise_get_daily_review`.
2. Ignore deadlines, stage moves, and business alerts (deal-at-risk, decision-revisit) except to note that CoS owns them.
3. Keep duplicate alert storms, proposed events sitting with no owner, and a fault already filed whose evidence ids changed.
4. For a keeper: `forvex_remember` kind `system_fault`, then `fault_escalated` if CoS needs it this week.
5. Message CoS in Grok:

```
You own the decision (from Platform).
ask: <one imperative — usually acknowledge, dismiss, or put on the week>
context: <ids and one sentence>
done_when: <checkable>
priority: now | this_week
```

6. If nothing qualifies, stop after one line in the Platform thread. Do not emit.

### Ritual — file an idea

When Paul or another Bot messages an idea:

1. Restate it in one sentence. Ask one question only if the repo or the evidence is missing and the idea cannot be filed without it.
2. `forvex_remember` kind `feature_idea`. Text begins `Feature idea:`.
3. Reply with `insight_id` and whether it is `filed` or `duplicate`.
4. Do not emit. Do not write a packet until the Friday digest or until Paul says "make this a packet."

### Ritual — Friday digest

1. Recall feature ideas and system faults as above.
2. Split into wishes (no repo, no acceptance) and ready (packet can be written).
3. For each ready item not already offered, write the six-line packet, remember it if the text grew, emit `packet_offered`.
4. Emit `digest_sent`.
5. Message CoS with the ready titles and the wish count. CoS chooses what enters the week.

### Ritual — packet accepted

CoS or Paul says a packet is going to Cursor. Platform does not open Cursor. Reply with the six lines and the `insight_id`, then stop.

## CoS addition

Owner map row:

| Signal | Hand to |
|--------|---------|
| System fault, duplicate alert storm, feature idea, Cursor packet | Platform Bot / `platform` |

CoS still decides the week. Platform does not.

## Test plan

- Emit a workspace `digest_sent` on lane `platform` in the emit unit test. Confirm `not_a_lane` still fails.
- Skill dry run against a review that is all business alerts: no emit, no CoS message.
- File the same feature idea twice: second call returns `mode: "duplicate"`.
- Recall `feature idea` plus `lane: platform` returns it.
- Friday test run emits one `digest_sent` and does not message Paul.
- Confirm a `packet_offered` row appears in the next `readvise_get_daily_review` proposed events.

## Out of scope

Blog / Social / Strategy bots. Flip Manager and Property Manager. An HR bot. A second underwriting bot. Local-execution access to the repos. Auto-launching a Cursor agent. `forvex_list_lane_events`.
