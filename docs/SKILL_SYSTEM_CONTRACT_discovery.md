# Phase 1 Discovery — Skill + MCP Horizontal Contract

**Date:** 2026-06-03  
**Scope:** recontrol, readvise, reecosystem-core, redeal-mobile  
**Purpose:** Inventory architecture docs, skills, MCP tools, and report contradictions/gaps across five horizontal concerns. Read-only discovery; no fixes applied here.

---

## 1. Architecture / contract / schema / plan doc inventory

| Repo | Path | Authoritatively owns | Current / stale |
|------|------|----------------------|-----------------|
| redeal-mobile | `skills/ARCHITECTURE.md` | Vertical skill stack, layer responsibilities, IP model, multi-platform portability | **Stale:** skill tree omits `readvise-capture`; lists rehab as "concept only" (CONCEPT exists, no SKILL.md); says "Readvise MCP server (future)" while tools ship on recontrol MCP |
| redeal-mobile | `skills/ROADMAP.md` | Phased skill parity plan (Phase 0–6) | **Partially stale:** Phase 0 lists "four strategies" in exit criteria; server now has six; MCP phases supersede parts of roadmap |
| redeal-mobile | `skills/MCP_BUILD_SEQUENCE.md` | Executable MCP build plan, pre-build decisions, phase status | **Current** for build history; rehab tools marked blocked (§2.6) |
| redeal-mobile | `skills/MCP_BUILD_INVESTIGATION.md` | DB write paths, idempotency keys, tool→table mapping | **Current** reference for write discipline design |
| redeal-mobile | `docs/comps_v2_contract.md` | Comps three-shape model (`CompTrace`, `GetCompsResponse`, `CompCheckResult`) | **Current** engine contract; status: draft; references missing `comp_intelligence_plan.md` sibling correctly |
| redeal-mobile | `docs/comp_intelligence_plan.md` | Mobile comp-check expansion (bands, confidence, investor signals) | **Superseded in part** by recontrol comps v2 implementation; still authoritative for mobile v1 `CompCheckResult` fields |
| redeal-mobile | `docs/FORVEX_MULTI_REPO_REFACTOR_BRIEF.md` | Multi-repo refactor goals, six-strategy taxonomy, buy-box demotion | **Current** operating plan |
| redeal-mobile | `docs/plans/comps_v2_recontrol_implementation.md` | Implementation notes for comps v2 in recontrol | **Current** (implementation companion) |
| redeal-mobile | `skills/forvex-rehab-estimator/CONCEPT.md` | Rehab skill + MCP tool surface (planned) | **Current** concept; not implemented |
| redeal-mobile | `readvise_core_readvise_redeal_schema.sql` | Full pg_dump snapshot (core + readvise + redeal) | **Stale** (2026-01-31); missing recent migrations (e.g. `core.comp_traces` May 2026) |
| recontrol | `docs/MCP_REBUILD_HANDOFF.md` | MCP transport, auth, tool registry, REbuild integration | **Current** |
| recontrol | `lib/mcp/tools/registry.ts` | Live MCP tool registry (23 tools) | **Current** |
| recontrol | `lib/mcp/tools/outputSchemas.ts` | Wire output Zod shapes | **Current** (`TOOL_SCHEMA_VERSION` 0.3.0) |
| recontrol | `lib/mcp/underwrite/contracts.ts` | Underwriting input/output Zod | **Current** |
| recontrol | `lib/mcp/buybox/constants.ts` | Six-strategy enum + labels | **Current** canonical enum |
| recontrol | `lib/mcp/comps/trace/compTraceTypes.ts` | Comp trace types + comps confidence labels | **Current** |
| recontrol | `lib/mcp/deals/dealWritebackTypes.ts` | Deal lifecycle status enum for writes | **Current** |
| recontrol | `lib/supabase/database.types.ts` | Generated DB types incl. `deal_links` | **More current** than pg_dump (2026-05-28) |
| readvise | `docs/operate/PUSH_UNDERWRITING_SEMANTIC_MAP.md` | Readvise display of underwriting fields | **Vertical** (Readvise-owned) |
| readvise | `lib/types/preferences.ts` | Duplicated `FORVEX_STRATEGY_*` + UI prefs types | **Duplicate** of recontrol buybox constants — manual sync |
| readvise | `lib/comps/types.ts` | Mirrored comp trace types | **Duplicate** — "keep in sync" comment |
| reecosystem-core | `ARCHITECTURE.MD` | Multi-app bounded write ownership, canonical spines | **Current design intent**; omits `deal_links`, MCP contracts, strategy enums |
| reecosystem-core | `CONTRIBUTING.md` | Migration/RLS checklist | **Current** |
| reecosystem-core | `20260408110000_sense_input_snapshots_rls_include_market_ids.sql` | RLS patch | **Misplaced orphan** — duplicate exists in readvise migrations |

**Not found:** standalone `comp_intelligence_plan.md` outside redeal-mobile (only referenced from `comps_v2_contract.md:3`).

---

## 2. Skill inventory

| Skill | Triggers | Inputs | MCP reads | MCP writes | Outputs |
|-------|----------|--------|-----------|------------|---------|
| **forvex-underwriting** | `SKILL.md:2-18` — address + price/ARV/rehab; six strategies; MAO; what-ifs | Address, purchase, ARV, rehab (+ rent, condition) | `forvex_get_property`, `list_deals`, `get_deal`, `get_deal_history`, `get_buy_box`, **`forvex_underwrite`**, flood, market, comps*, rent | **`forvex_save_deal`** (explicit save only) | Deal one-pager; mini what-if deltas |
| **forvex-onboarding** | `SKILL.md:2-16` — buy-box setup/update | 9-batch interview fields | `forvex_get_buy_box` | **`forvex_save_buy_box`** | Summary table; optional `my-buy-box.md` export |
| **forvex-appointment-prep** | `SKILL.md:2-17` — prep/brief/meeting at address | Address + seller context | Same read set as underwriting (via `forvex_underwrite` as SoT) | **`forvex_update_deal_disposition`**, **`forvex_log_activity`** | Appointment brief (9 sections); probability band |
| **forvex-presentation** | `SKILL.md:2-18` — dashboard/deck/PDF | Prior analysis in conversation | MCP **resources** (`forvex://deal/...`) — not live tools | None | HTML artifact (dashboard/slides/PDF) |
| **readvise-capture** | `SKILL.md:2-16` — note/task/pulse/advisor/quick | Intent body; property query | `readvise_resolve_property`, `readvise_get_today_summary`, `forvex_list_deals` | **`readvise_create_*`**, **`readvise_append_pulse_today`** | Preview + confirmation + row id |
| **forvex-rehab-estimator** | *Not defined* (CONCEPT only) | sqft, tier, or component checklist | Planned: property, `estimate_rehab_*`, catalog | Planned: **`save_rehab_estimate`** | Priced estimate → feeds underwriting |

\* Comps tools optional; underwriting consumes ARV via `forvex_underwrite` which calls comps internally.

---

## 3. MCP tool inventory (recontrol)

All tools registered in `recontrol/lib/mcp/tools/registry.ts:36-61`. Implementation repo: **recontrol**.

| Tool | Read / write | Key tables |
|------|--------------|------------|
| `forvex_whoami` | Read | `core.workspace_members`, `core.workspaces` |
| `forvex_get_property` | Read (+ cache upsert) | `core.properties`, `core.property_api_cache`, `core.property_valuations` |
| `forvex_get_deal` | Read | RPC `readvise.rpc_get_underwriting_snapshot_v2` |
| `forvex_get_deal_history` | Read | `core.deals`, `core.deal_analyses`, `core.deal_status_events`, `readvise.readvise_property_notes` |
| `forvex_list_deals` | Read | `core.deals`, `core.properties`, **`core.deal_links`**, `redeal.deals` |
| `forvex_get_comps` | Read (+ trace write) | `core.comp_traces`, `core.property_api_cache` |
| `forvex_get_comps_expanded` | Same as comps | Same |
| `forvex_get_comp_detail` | Read | `core.comp_traces` |
| `forvex_attach_analysis` | Write | `core.property_research` |
| `forvex_get_market_intelligence` | Read (+ cache) | Sense tables, `core.property_market_context`, `core.market_briefing_cache` |
| `forvex_get_buy_box` | Read | `core.franchisee_prefs` (+ legacy redeal fallbacks) |
| `forvex_save_buy_box` | Write | `core.franchisee_prefs` via RPC |
| `forvex_save_deal` | Write | `core.deals`, `core.deal_analyses`; best-effort `readvise.readvise_properties` |
| `forvex_update_deal_disposition` | Write | `core.deals`, `core.deal_status_events` |
| `forvex_log_activity` | Write | `readvise.readvise_property_notes`, `readvise.readvise_timeline_events` |
| `forvex_get_rent_estimate` | Read | Rentometer edge; optional property snapshot |
| `forvex_get_flood_data` | Read (+ cache) | `core.property_api_cache` |
| `forvex_underwrite` | Read-only orchestration | Composes property/comps/market/buy-box reads; **no persistence** |
| `readvise_resolve_property` | Read | `readvise.readvise_properties` |
| `readvise_create_property_note` | Write | `readvise.readvise_property_notes` |
| `readvise_create_task` | Write | `readvise.readvise_tasks` |
| `readvise_append_pulse_today` | Write | `readvise.readvise_pulse_entries`, `readvise.readvise_pulse_properties` |
| `readvise_create_advisor_action` | Write | `readvise.readvise_pulse_entries` |
| `readvise_get_today_summary` | Read | pulse, tasks, notes tables |

**Planned, not registered:** `estimate_rehab_quick`, `estimate_rehab_components`, `get_rehab_cost_catalog`, `save_rehab_estimate`, `get_rehab_estimate` (`CONCEPT.md:72-141`; `MCP_BUILD_SEQUENCE.md:348`).

---

## 4. Contradiction + gap report

### a. Identity namespace

**Canonical IDs (authoritative):**

| ID | Minted by | Namespace |
|----|-----------|-----------|
| `workspace_id` | Core workspace membership | `core.workspaces.id` |
| `property_id` (MCP) | `core.upsert_property` / resolve | `core.properties.id` |
| `deal_id` (MCP forvex_* tools) | `core.save_deal_analysis` RPC | **`core.deals.id`** |
| `readvise_property_id` | Readvise property create | `readvise.readvise_properties.id` — linked via `canonical_property_id` |

**`core.deal_links` mapping** (`readvise_core_readvise_redeal_schema.sql:14134-14142`; used `listDeals.ts:113-119`):

```
(workspace_id, source_app, source_deal_id) → canonical_deal_id
```

- Example: `source_app='redeal'`, `source_deal_id=redeal.deals.id` → `canonical_deal_id=core.deals.id`
- **No MCP tool writes `deal_links`** today
- MCP `forvex_list_deals` enriches financials from `redeal.deals` via this join

**Rehab CONCEPT.md §9.3 resolution:**

> "Is `deal_id` the Readvise deal id?"

**Answer: No.** MCP `deal_id` is **`core.deals.id`** (canonical lifecycle spine per `reecosystem-core/ARCHITECTURE.MD:135-140`). Readvise uses `readvise_property_id` for pipeline/notes. Legacy `redeal.deals.id` resolves through `deal_links`. Planned `save_rehab_estimate({ deal_id })` must use **`core.deals.id`**; projection to `redeal.deals` thick fields happens server-side (`MCP_BUILD_INVESTIGATION.md:232`).

**Gaps:**
- `ARCHITECTURE.MD` documents `canonical_deal_id` on redeal tables but **not** `deal_links` table
- `forvex_get_deal` accepts optional `readvise_property_id` — cross-namespace bridge exists but undocumented in horizontal contract until now
- `property_links` table exists (`database.types.ts:1283`) but unused in MCP skill flows

---

### b. Source-of-truth per number

| Value | Producing tool / engine | Consumers | Drift risk |
|-------|-------------------------|-----------|------------|
| **ARV** | `forvex_get_comps` → `arv.median` (engine); consumed by `forvex_underwrite` (`runUnderwrite.ts:246-271`) | underwriting skill, appointment-prep, presentation | **HIGH** if skill recomputes ARV from raw comps — `comps_v2_contract.md:27-31` warns explicitly |
| **As-is value** | `forvex_get_comps` → `as_is_value` (`mapGetCompsV2Output.ts:270`) | comps viz; not yet wired into underwriting input | Low today; gap if skill starts inferring |
| **Rehab (detailed)** | User input OR `forvex_underwrite` tier estimate (`runUnderwrite.ts:276-292`) OR planned `estimate_rehab_*` | underwriting, appointment-prep pre-offer | **HIGH:** `underwrite.py`, `nativeEngine.ts`, `runUnderwrite.ts`, skill `assumptions.md:236-241`, `appointment-prep/SKILL.md:206` all embed tier rates |
| **Rehab (saved on deal)** | Not yet — planned `save_rehab_estimate` → `redeal.deals.*_rehab_estimate` | `forvex_get_deal`, `runUnderwrite` existing-deal defaults | Blocked until rehab MCP ships |
| **Rent** | `forvex_get_rent_estimate` OR user override; `forvex_underwrite` resolves (`runUnderwrite.ts`) | underwriting rental/BRRRR | Medium if skill guesses rent |
| **MAO / pre-offer** | `forvex_underwrite` / `nativeEngine.ts` (`mao*` functions) | underwriting, appointment-prep | **HIGH** if skill runs `underwrite.py` locally while MCP connected |
| **Buy-box (resolved)** | `forvex_get_buy_box` + injection in `runUnderwrite.ts:86-120` | `forvex_underwrite` | **HIGH:** skill `assumptions.md:7-12` still lists `my-buy-box.md` as precedence #2 over server |
| **Verdict** | `forvex_underwrite` (`nativeEngine.ts:813`) | all analysis skills | Local `underwrite.py` fallback can disagree |
| **deal_score** | `forvex_underwrite` per-strategy scores (`nativeEngine.ts:777-782`) | one-pager, save snapshot | Saved via `forvex_save_deal` analysis blob |
| **best_strategy** | `forvex_underwrite` | presentation, saves | Same |

**Second producers to flag:**
- `scripts/underwrite.py` — offline fallback (`SKILL.md:123-125`)
- Skill prose in `references/calculations.md`, `badges-and-scoring.md`, `guardrails.md`
- Mobile `comp-check` edge (legacy) vs recontrol comps v2 engine
- `forvex_get_property.estimated_arv` as ARV fallback (`runUnderwrite.ts:259`) — lower confidence tier

---

### c. Canonical enums / constants

#### Strategy taxonomy (target: 6 strategies)

| Location | Values | Issue |
|----------|--------|-------|
| `recontrol/lib/mcp/buybox/constants.ts:1-8` | assignment, wholesale, wholetail, retail_flip, rental, brrrr | **Canonical** |
| `readvise/lib/types/preferences.ts:144-151` | Same 6 | Duplicate copy |
| `redeal-mobile/.../normalizeInputs.ts` | retail_flip, wholetail, wholesale, rental only | **Missing assignment, brrrr** |
| `ROADMAP.md:52` | "all four strategies" | Stale count |

#### Rehab condition tiers

| Location | Values | Issue |
|----------|--------|-------|
| `recontrol/lib/mcp/underwrite/contracts.ts:20` | light, medium, heavy, gut | **Canonical for underwriting** |
| `REbuild3/rebuild3/lib/engine/types.ts` | none, light, medium, heavy (per category) | Different domain (`gut` vs `none`) |
| `readvise/lib/types/preferences.ts:39-43` | RehabRates: light/medium/heavy only | **Missing gut** |

#### Tier $/sqft rates (duplicated authoritative values — must stay server-side)

| Location | Citation |
|----------|----------|
| `recontrol/lib/mcp/underwrite/runUnderwrite.ts:22-27` | light/medium/heavy/gut rates |
| `recontrol/lib/mcp/underwrite/nativeEngine.ts:56` | Same |
| `redeal-mobile/skills/.../underwrite.py:116` | Same |
| `assumptions.md:236-241` | Documented in skill |
| `appointment-prep/SKILL.md:206` | Inline in skill |
| `CONCEPT.md:88` | Documented in concept |

#### Confidence labels (three vocabularies — not interchangeable)

| Domain | Labels | Location |
|--------|--------|----------|
| Comps | high, medium, low, fail | `compTraceTypes.ts:16` |
| Underwriting | limited, partial, full | `contracts.ts:57` |
| Rent estimate | provider-specific | `loadRentEstimate.ts` passthrough |

#### Deal lifecycle status (internal drift)

| Location | Values | Issue |
|----------|--------|-------|
| `dealWritebackTypes.ts:9-18` | LEAD, OFFER, UNDER_CONTRACT, … LOST | Used by write tools |
| `constants.ts:9-18` | Lead, Offer, Under Contract, Contract, … | Title Case + extra `Contract` — **unused by write tools** |

---

### d. Write discipline

| Tool | Confirmation | Idempotency | Field ownership | Clobber risk |
|------|--------------|-------------|-----------------|--------------|
| `forvex_save_deal` | Skill requires explicit save (`SKILL.md:149-165`) | `idempotency_key` UUID (`saveDeal.ts:29-34`, `143-145`) | Appends analysis to `core.deal_analyses`; does **not** change lifecycle status (`SKILL.md:45`) | Low vs disposition; **redeal thick fields** only via projection (not direct MCP write today) |
| `forvex_update_deal_disposition` | Skill confirms with user (`appointment-prep/SKILL.md:126-131`) | None — each call creates status event | **`core.deals.current_status`** only | Could conflict if another writer sets status out-of-band |
| `forvex_save_buy_box` | Onboarding confirms (`onboarding/SKILL.md:171-178`) | `merge` flag + RPC upsert | **`core.franchisee_prefs`** | Overwrites prefs keys on merge=false |
| `forvex_log_activity` | Implicit on user statement post-meeting | None documented | **`readvise.readvise_property_notes`** | Append-only; low clobber |
| `readvise_create_*` | Preview + confirm unless `quick:` (`readvise-capture/SKILL.md:27-28`) | None | Readvise pulse/tasks/notes | Independent namespace |
| `save_rehab_estimate` (planned) | Not built | Planned upsert on deal_id (`CONCEPT.md:183`) | **`redeal.deals.*_rehab_estimate`** per investigation | **Clobber risk with `forvex_save_deal` analysis.rehab** if both write rehab without coordination |

**System-wide gap:** `calc_version` required on engine outputs (`nativeEngine.ts:3`); `schema_version` on comps (`compTraceTypes.ts:3`); not enforced uniformly on all write payloads.

---

### e. Trigger / routing precedence

**Collision examples:**

| User phrase | Possible routes |
|-------------|-----------------|
| "log the rehab on 123 Main" | readvise-capture (note), forvex-rehab-estimator (estimate), forvex-underwriting (rehab input) |
| "note that seller wants 180" | readvise-capture, forvex-underwriting (context) |
| "save this deal" | forvex-underwriting (`save_deal`), readvise-capture (misclassified pulse?) |
| "prep me for 123 Main" | forvex-appointment-prep, forvex-underwriting (overlap) |
| "what's the rehab" | rehab-estimator, underwriting follow-up |
| "update my buy-box" | forvex-onboarding, forvex-underwriting (override) |

**Proposed precedence (for `SKILL_SYSTEM_CONTRACT.md`):**

1. **Explicit skill prefixes win:** `quick:`, `pulse:`, `advisor lane:`
2. **Capture vs analysis:** If intent is *record keeping* (note/task/pulse/recap) → **readvise-capture**. If intent is *numbers/verdict/offer* → **forvex-underwriting** or **appointment-prep**.
3. **Rehab estimation:** Structured walkthrough or "estimate rehab" → **forvex-rehab-estimator** (when live). Bare rehab dollar in underwriting context → **forvex-underwrite** input, not capture.
4. **Appointment language** ("prep", "meeting tomorrow", "seller brief") → **forvex-appointment-prep** over underwriting.
5. **Presentation language** ("dashboard", "deck", "PDF") → **forvex-presentation** after analysis exists.
6. **Buy-box setup** ("onboard", "set up my buy-box") → **forvex-onboarding** only.
7. **Tie-break:** Prefer the skill that **writes least** until user confirms (capture and save flows require explicit confirm).

---

## 5. Assumptions & open decisions (unresolved from code)

1. **Flat vs nested ARV in comps MCP output** — open in `comps_v2_contract.md:472-475`
2. **Rehab MCP hosting** — extend recontrol MCP (recommended `CONCEPT.md:53`) vs separate server
3. **Rebuild engine API surface** — blocks rehab tools (`MCP_BUILD_SEQUENCE.md:362`)
4. **`deal_links` migration provenance** — DDL only in pg_dump, no CREATE migration in repos
5. **`DEAL_STATUSES` vs `DEAL_LIFECYCLE_STATUSES`** — consolidate or delete unused constant
6. **`forvex-presentation` MCP resources** — documented but not in `registry.ts`
7. **reecosystem-core** — not a git repo; shared types package never created
8. **Whether `forvex_save_deal` should accept `deal_id`** to target existing deal vs property-only create

---

## 6. Recommended Phase 3 deletions (duplicated values → pointers)

| File | Duplication | Action |
|------|-------------|--------|
| `forvex-appointment-prep/SKILL.md:206` | Inline $/sqft rates | Replace with pointer to server engine |
| `forvex-underwriting/references/assumptions.md:236-241` | Tier rate table | Replace with pointer to `recontrol/lib/mcp/underwrite/nativeEngine.ts` |

Do **not** delete `underwrite.py` rates — offline fallback remains valid with pointer comment only.
