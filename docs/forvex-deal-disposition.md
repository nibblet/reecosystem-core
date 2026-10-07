# Deal Disposition Skill (Shared Reference)

**Status:** Shared procedure for `forvex_update_deal_disposition`  
**Owner:** reecosystem-core  
**Used by:** `forvex-appointment-prep`, `cos-lane`, `pm-lane`, any skill that moves deals or sets timeline dates

> This is a **shared reference**, not an uploadable `.skill`. Skills that call
> `forvex_update_deal_disposition` (status moves or date updates) follow this
> procedure. Lane bots (CoS, COO, PM) point here; do not duplicate this logic.

---

## MCP tool

**`forvex_update_deal_disposition`** (forvex-control)

Moves a deal through the lifecycle and/or sets timeline dates.

---

## 1. Resolve the deal

Before calling the tool you need `deal_id` (a `core.deals.id` UUID).

1. If the user gave an address, call `forvex_get_property({ address })` → `property_id`.
2. Call `forvex_list_deals({ property_id })` → pick the active deal (or ask if multiple).
3. If no deal exists for the property, stop: "No deal found for that property."

---

## 2. Parse any dates the user stated

The tool accepts six optional timeline dates (ISO `YYYY-MM-DD`, strictly validated):

| Field | Meaning | Typical source |
|-------|---------|----------------|
| `lead_date` | When the deal entered the pipeline | "We got this lead on March 5" |
| `contract_date` | When the contract was signed | "Contract was signed yesterday" |
| `option_expires_at` | When the option period ends (deal-at-risk) | "Option expires April 20" |
| `expected_close_date` | Scheduled closing (deal-at-risk) | "Closing is set for May 1" |
| `purchase_date` | Actual acquisition date | "We closed on the purchase April 28" |
| `sale_date` | Actual disposition date | "Sold to the end-buyer June 15" |

**Parse rules:**

- Resolve relative expressions ("yesterday", "next Tuesday", "in two weeks") to `YYYY-MM-DD` from today's date.
- Never invent a date. If the user did not state it, do not pass it.
- Never default to today as a timeline date — these are historical or scheduled facts.

**Closing statement mapping:**

When a closing/settlement statement is uploaded and parsed, map its `settlement_date` based on the parties:

- **Buyer matches the workspace entity** → `purchase_date` (acquisition)
- **Seller matches the workspace entity** → `sale_date` (disposition)
- **Neither or both match** → ask the user which date field applies

---

## 3. Check property_id linkage

Timeline dates persist to `readvise_properties` (the Operate Timeline). This requires the deal to have a linked `property_id`.

Before attempting a date write:

1. Pull the deal: `forvex_get_deal({ id: deal_id })`.
2. Check `property_id` on the response.
3. If `property_id` is missing or null: **stop and tell the user** — "This deal has no linked property. Timeline dates cannot be saved until the deal is associated with a property."

Do **not** attempt the write; it will fail server-side.

---

## 4. Echo-back / confirmation gate

Before writing, echo back everything the user will see change. This is mandatory unless the skill explicitly opts out (e.g. `quick:` capture).

**Format:**

```
I'll update <deal address/id>:
  Status: <current> → <new_status>  [if status is changing]
  Dates:
    lead_date: <value>              [only if user gave it]
    contract_date: <value>
    option_expires_at: <value>
    expected_close_date: <value>
    purchase_date: <value>
    sale_date: <value>
  Notes: "<notes>"                  [if provided]

Confirm? (yes / edit / cancel)
```

- List **only** the dates the user actually gave — do not list unchanged fields.
- If only dates are changing (no status move), say "Status: (unchanged)".
- If only status is changing (no dates), omit the Dates block.

---

## 5. Build and call the tool

Pass **only** the fields the user provided. Never pass empty or null for omitted dates.

```json
{
  "deal_id": "<uuid>",
  "new_status": "<STATUS>",
  "reason_code": "...",          // required for FOLLOW_UP, LOST, or same-status updates
  "notes": "...",
  "lead_date": "YYYY-MM-DD",     // only if user gave it
  "contract_date": "...",
  "option_expires_at": "...",
  "expected_close_date": "...",
  "purchase_date": "...",
  "sale_date": "..."
}
```

**Status rules (summary — see tool description for full list):**

- Sequential forward moves (LEAD→OFFER→UNDER_CONTRACT→INVENTORY→REHAB→LISTED→PENDING→SOLD) need no override.
- FOLLOW_UP requires `reason_code` from the follow-up list.
- LOST requires `reason_code` from the lost list.
- Same-status updates require `reason_code` (e.g. `timeline_update`, `follow_up_scheduled`, `counter_pending`).
- Skip/backwards/reopen-terminal require `override_reason`.

---

## 6. Dates-only update path

A date can change **without** a status move. In this case:

1. Set `new_status` to the **current** status of the deal.
2. Provide `reason_code` (same-status rule) — use a descriptive code like `timeline_update` or one that fits context.
3. The tool treats this as a same-status update and persists dates.

**Example — updating expected_close_date only:**

```json
{
  "deal_id": "...",
  "new_status": "UNDER_CONTRACT",
  "reason_code": "timeline_update",
  "expected_close_date": "2026-05-15",
  "notes": "Closing pushed to May 15 per lender"
}
```

---

## 7. Confirm result

After the call returns:

1. Check for `timeline_updated: true` — this confirms dates were persisted to `readvise_properties`.
2. If the response shows `timeline_updated: false` or is missing, dates were **not** written — check whether `property_id` was missing (step 3).
3. Report the outcome to the user: "Done — status is now UNDER_CONTRACT and the timeline dates are saved."

---

## Error handling

| Condition | Action |
|-----------|--------|
| Deal not found | "No deal found with that ID." |
| No linked `property_id` | Stop before write: "Deal has no linked property — cannot save timeline dates." |
| Invalid date format | The tool rejects non-ISO dates — surface the error and ask user to clarify. |
| Missing required `reason_code` | Add the required code or ask user which reason applies. |

---

## Non-goals

- This skill does **not** modify MCP tool behavior, stage/transition rules, or deal_at_risk alerts.
- Never invent or default dates; today's date is never written as a timeline date.
- No data backfills.

---

## Related

| Document | Relationship |
|----------|--------------|
| `SKILL_SYSTEM_CONTRACT.md` §3.4 | Deal lifecycle status enum |
| `SKILL_SYSTEM_CONTRACT.md` §6.2 | Field ownership — `forvex_update_deal_disposition` owns `current_status` |
| `forvex-skills/skills/forvex-appointment-prep/SKILL.md` | Appointment-prep skill that uses this procedure |
| `My_COS.md`, `My_COO.md` | Lane bots that reference this for disposition/date handling |
