# forVEX Website Copy Research — 2026-06-06

> **Scope:** Product repos on Lexar (`redeal-mobile`, `REbuild3`, `readvise`, `REpost`, `reecosystem-core`, `recontrol`).  
> **Not in workspace:** `reecosystem-web` (marketing site repo) — not found on Lexar; current website baseline copy was supplied in the research brief.  
> **Instruction:** Facts and evidence only. Final marketing copy is a separate step.

---

## Executive summary

> **Update (2026-06-06):** Product/marketing decisions below supersede repo-only findings where they conflict. See [Messaging Addendum](#messaging-addendum--approved-decisions-2026-06-06) for full approved framing.

- **Lead with agentic, not app-first.** Deal copy should default to **“Talk to your deal in Claude”** — Skills + model-agnostic MCP + server-side business rules — not the legacy mobile-app story. Apps remain for review, field walkthrough (Build), and visual command center (Edge). Parity work in progress.
- **Platform metaphor:** **Investment operating layer** (not “operating system”). **Forge** = whole platform sharpened by real operations. **VEX** = AI interaction layer across products. **Advise** = Edge workspace name only.
- **Edge workspace split:** **Sense** = market intel (live Kentucky markets). **Track** = portfolio truth. Operate holds property-level summary but not the portfolio claim.
- **Post** = express step parallel to lifecycle; legacy [`repost.reecosystem.app`](https://repost.reecosystem.app/workspace?section=create&view=generate) → redirect to `post.forvex.app` when migrated.
- **Competitive angle:** vs. point-solution apps *and* vs. AI bolted onto legacy UIs — forVEX exposes proprietary logic to agents via MCP so model improvements compound without rebuilding apps.
- **Control:** omit from homepage; optional “How it works” footnote only. MCP URL not on public site yet.

---

## Ecosystem lifecycle map

| Lifecycle stage | Primary app | What happens | Verified handoff |
|-----------------|-------------|--------------|------------------|
| **Source / market context** | forVEX Edge (Sense) | Tract/market intelligence, neighborhood posture | Sense API consumed by Deal Summary (“Market Posture”) when Edge URL configured |
| **Offer / underwriting** | forVEX Deal | Fast Mode or Deal Prep → four-strategy matrix, Deal Intel | Creates `core.properties` + `core.deals`; writes `redeal.*` overlay |
| **Rehab scope / estimate** | forVEX Build | Profile-driven SOW, walkthrough, triangulation, audit | Project from `core.deals`; estimate applies back to Deal lifecycle bar |
| **Operate / pipeline** | forVEX Edge (Operate) | Property pipeline, notes, checklists, tasks | Deal pushes underwriting via webhook/sync; pipeline stage owned by Edge |
| **Learn / reflect** | forVEX Edge (Reflect) | Pulses, weekly rollups, sentiment | Reflect feeds summaries back into platform |
| **Portfolio performance** | forVEX Edge (Track) | KPIs, conversion, capital efficiency | **Portfolio truth** lives here; Operate has property-level summary only |
| **Express / brand** | forVEX Post | Recollection-grounded content → approve → publish | Parallel to lifecycle; recollections from Deal/Build/Edge (optional) |

```
Source ──► Deal (underwrite) ──► Build (scope/estimate) ──► Edge (operate/track)
   ▲              │                      │                         │
   └─ Sense ──────┘                      └──── recollection ───────┼──► Post (publish)
```

**Shared spine (verified):** `core.properties`, `core.deals`, workspace entitlements, Supabase auth. Authoritative business rules and MCP tools live server-side (forVEX Control — internal; mention in “How it works” only, not homepage).

---

## forVEX Deal

### Product truth

1. **One-sentence definition:** Field-ready deal underwriting app that runs four strategies (Wholesale, Wholetail, Retail Flip, Rental) with deterministic math and AI interpretation, designed for fast analysis on mobile or web.

2. **Primary user:** Individual investors, small acquisition teams/partnerships, franchise/multi-market operators, and on-the-go users analyzing from appointments or poor connectivity (`redeal-mobile/_startup/initial-prd.md` L15–29).

3. **Job to be done:**  
   - **Before:** Spreadsheets, bulky CRMs, slow or inconsistent offer math in the field.  
   - **After:** Complete deal analysis in under 60 seconds (product goal), with transparent formulas, buy-box fit, and optional AI guidance — online or offline (`redeal-mobile/redeal-mobile/docs/PRD.md` L41–58; `initial-prd.md` L7–11).

4. **Top capabilities (user-visible):**
   - **Deal Manager** — list, filters, sync status, archive
   - **Fast Mode** — single-screen ARV/Offer/Rehab → Run Deal Analysis
   - **Deal Prep Wizard** — 5-step prep + review (property, market, seller, equity, underwriting)
   - **Deal Summary** — Best Strategy, strategy cards, Market Posture (Sense)
   - **Deal Intel** — Quick Questions (deterministic), Deal Position, Gut Check, Ask Analyst
   - **Settings** — Investor Profile, Buy Boxes, Assumptions, AI Behavior
   - **Lifecycle bar** — Deal Prep → Rebuild → Readvise handoffs on Summary

5. **Differentiators (documented):**
   - Four-strategy matrix always computed, not a single-strategy calculator (`PRD.md` L7–8)
   - Deterministic engine + AI that interprets but does not invent numbers (`ask-analyst.md`; Analyst welcome in `AnalystChatScreen.tsx`)
   - Offline-capable with SQLite + sync queue (`initial-prd.md` L194–211)
   - “Pocket underwriter,” not full CRM (`initial-prd.md` L65; `PRD.md` L58)
   - Workspace entitlements for team use without suite lock-in (`access-control-doc.md`)

6. **AI role and limits:**
   - **AI does:** Ask Analyst chat, Deal snapshots, neighborhood briefing (qualitative), Gut Check / Investment Committee reads, optional Sense polished copy
   - **Deterministic:** Quick Questions, all calculator/strategy math, buy-box fit, deal scoring
   - **Limits:** No invented comps/stats; no formula changes; offline disables AI snapshots; stateless analyst sessions; no legal/tax/negotiation scripting (`initial-prd.md` L689–695, L2618–2624)
   - **Fallback:** Without OpenAI → deterministic responses + “AI unavailable” banner

7. **Platforms & availability:**

   | Platform | Status | Source |
   |----------|--------|--------|
   | iOS | Primary; EAS dev/internal/production; iPad supported | `app.json`, `eas.json` |
   | Web | Shipped static export; `deal.forvex.app`; forVEX Deal branding | `package.json`, `.env.example`, `WEB_DEPLOYMENT.md` |
   | Android | Configured in Expo; no production EAS profile found | `app.json`; `eas.json` |
   | Version | 1.0.0 | `app.json` L6 |

8. **Integration with other forVEX apps (verified today):**
   - **Edge:** Push underwriting from Summary; Sense Market Posture on Deal Summary; sync indicator on deal cards; requires `EXPO_PUBLIC_READVISE_API_URL`
   - **Build:** Lifecycle “Rebuild” segment applies latest Rebuild estimate to deal rehab (must exist in Build first)
   - **Post:** Entitlement in schema only — **no in-app Post workflow found**
   - **Control:** MCP underwriting tools authoritative server-side (`FORVEX_MULTI_REPO_REFACTOR_BRIEF.md` L31–34)

9. **What it replaces (documented):** Spreadsheets, bulky CRMs for deal analysis, generic single-strategy calculators (`initial-prd.md` L20, L65–71).

10. **Honest limitations:**
    - Export Center (PDF/CSV) marked not started in Dec 2024 PRD — verify before claiming
    - Rentometer, comps, AI, Sense, Edge push require internet
    - “Under 60 seconds” is a product goal, not benchmarked
    - PRD status doc (Dec 2024) contradicts shipped auth screens — treat `docs/redeal-user/` as UX source of truth
    - Fast Mode skips seller/market/finance capture (`fast-mode.md` L29–30, L40)

### User journeys

**Journey 1 — Fast field triage**  
- **Trigger:** At seller appointment; need go/no-go quickly  
- **Steps:** Open Fast Mode → enter address, ARV, offer, rehab tier → optional Rentometer → Run Deal Analysis  
- **Outcome:** New deal with full strategy matrix and Best Strategy visible on Summary  
- **Time-to-value:** Product goal “under 60 seconds” (`initial-prd.md` L8)

**Journey 2 — Full underwriting**  
- **Trigger:** Serious offer; need structured prep  
- **Steps:** Deal Manager → New Deal (Deal Prep Wizard) → 5 steps + Review → Deal Summary → Strategy Detail → Apply Strategy  
- **Outcome:** Saved deal with prep data, strategy selection, action pills (Photos, Notes, Deal Intel)

**Journey 3 — Ecosystem handoff**  
- **Trigger:** Deal approved; need rehab scope and pipeline tracking  
- **Steps:** Deal Summary lifecycle bar → Rebuild (apply estimate) → Readvise (push underwriting)  
- **Outcome:** Rehab number on deal; underwriting in Edge pipeline; copy: “Lifecycle managed in Readvise after this stage” (`SummaryScreen.tsx` area)

### Feature inventory

| Feature name (user-facing) | What it does | Primary surface | Maturity | Source file |
|---------------------------|--------------|-----------------|----------|-------------|
| Deal Manager | List/filter deals, sync status | Mobile + Web | GA | `docs/redeal-user/deal-manager.md` |
| Fast Mode | Single-screen quick underwriting | Mobile + Web | GA | `docs/redeal-user/fast-mode.md` |
| Deal Prep Wizard | 5-step structured deal intake | Mobile + Web | GA | `docs/redeal-user/deal-prep-wizard.md` |
| Deal Summary | Best Strategy, cards, Market Posture | Mobile + Web | GA | `docs/redeal-user/deal-summary.md` |
| Strategy Detail | Per-strategy economics (Flip, Wholetail, Wholesale, Rental) | Mobile + Web | GA | `docs/redeal-user/strategies.md` |
| Deal Intel | Quick Questions, snapshots, Gut Check | Mobile + Web | GA (AI partial offline) | `docs/redeal-user/deal-intelligence.md` |
| Ask Analyst | Deal-scoped AI chat with calculator tools | Mobile + Web | Beta/polish | `docs/redeal-user/ask-analyst.md`; PRD L19–21 |
| Settings / Buy Boxes | Investor profile, assumptions, AI behavior | Mobile + Web | GA | `docs/redeal-user/settings.md` |
| Market Posture (Sense) | Risk/posture from Edge Sense API | Mobile + Web | Beta (requires Edge URL) | `deal-summary.md`; `features.ts` |
| Lifecycle: Rebuild | Apply Build estimate to rehab | Mobile + Web | GA | `DealLifecycleBar.tsx` L28–36 |
| Lifecycle: Edge push | Push underwriting to Edge | Mobile + Web | GA | `DealLifecycleBar.tsx`; `SummaryScreen.tsx` |
| Export Center | PDF/CSV export | — | Planned / not started | `PRD.md` L31 |
| Workspace onboarding | Select workspace, entitlement gate | Mobile + Web | GA | `OnboardingScreen.tsx` |

### Messaging inputs

**Pain points (from docs):**
- Spreadsheets and bulky CRMs slow field decisions (`initial-prd.md` L20)
- Inconsistent underwriting across reps/markets (`initial-prd.md` L25–26)
- Spotty connectivity at appointments (`initial-prd.md` L5, L28–29)

**Outcome statements (verifiable framing):**
- Run all four strategies from one deal record (`PRD.md` L41–46)
- Same calculator and assumptions in Fast Mode and full prep (`fast-mode.md` L43–44)
- AI uses calculator outputs only — “no invented numbers” (`AnalystChatScreen.tsx` L66)

**Words/phrases used consistently:**
- Fast Mode, Deal Prep, Deal Intel / Deal Intelligence, Best Strategy, Market Posture, Ask Analyst, Quick Questions, Gut Check, Buy Box, Wholetail, Full / Partial / Minimal (rehab tiers)

**Words/phrases to avoid on website:**
- REdeal, RE:deal, Redeal (internal/repo; customer brand is **forVEX Deal**)
- Readvise / REadvise in customer copy (use **forVEX Edge**)
- “CRM replacement” (product explicitly avoids full CRM positioning)

**Proof points:**
- Version 1.0.0, production URL `deal.forvex.app` (env/docs)
- ~25 Jest test files for calculator logic (engineering quality, not customer proof)
- **Unknown:** customer count, deals analyzed, App Store ratings, testimonials

### Copy gaps vs. current website

| Current website | Repo truth | Gap |
|-----------------|------------|-----|
| “Web demo + iOS coming” | Web + iOS shipped at `deal.forvex.app`; v1.0.0 | **Understates maturity** |
| “Offer clarity when it counts” | Accurate; add four-strategy + deterministic math specificity | OK but vague |
| “Real-time guidance… market conditions” | Sense Market Posture requires Edge integration; not always on | **Conditional claim** |
| Features: New Deal, Fast Mode, Deal Intelligence, Settings | Missing: Deal Prep Wizard, Strategy Detail, Lifecycle handoffs, Ask Analyst | **Incomplete feature list** |
| “Context travels between apps” | Rebuild + Edge push verified; Post not connected | **Partially accurate** |

### Sources

- `/Volumes/Lexar/redeal-mobile/redeal-mobile/docs/PRD.md`
- `/Volumes/Lexar/redeal-mobile/_startup/initial-prd.md`
- `/Volumes/Lexar/redeal-mobile/docs/redeal-user/` (user docs set)
- `/Volumes/Lexar/redeal-mobile/redeal-mobile/app.json`
- `/Volumes/Lexar/redeal-mobile/redeal-mobile/app/components/summary/DealLifecycleBar.tsx`
- `/Volumes/Lexar/redeal-mobile/docs/FORVEX_MULTI_REPO_REFACTOR_BRIEF.md`
- `/Volumes/Lexar/reecosystem-core/ARCHITECTURE.MD` L15–33

---

## forVEX Build

### Product truth

1. **One-sentence definition:** Real estate rehab estimation and project execution platform where users configure quality profiles and severity levels to generate a Scope of Work, refine it in the field or at desk, and audit before committing.

2. **Primary user:** Real estate investment teams — acquisitions + rehab/PM staff — doing flip/rehab scope and cost control (`CONTEXT_PRD.md` L4).

3. **Job to be done:**  
   - **Before:** Manual line-by-line estimating, inconsistent rehab assumptions, cost overruns discovered late.  
   - **After:** Profile-driven SOW generation, deterministic totals, triangulation cross-checks, AI/heuristic audit, offline field estimating (`CONTEXT_PRD.md` L5–7).

4. **Top capabilities:**
   - **Library** — repair items, price books, rehab profiles, contractors
   - **New Estimate / Project vitals** — address, specs, profile selection
   - **Module walkthrough** — room-by-room severity signals → line items
   - **Text / conversational intake** — describe property → draft scope (AI-assisted)
   - **Estimate triangulation (v2)** — raw $/sqft, by-category, bottom-up + variance flag
   - **Deal audit** — LLM + heuristic warnings, confidence score, project badges
   - **SOW generation** — printable scope of work
   - **Project execution workspace** — scope, budget, contractors, updates (post-finalize)
   - **Create from Deal** — spawn project from eligible `core.deals`

5. **Differentiators (documented):**
   - “Configuration over Data Entry” — severity/profile drives SOW, not blank spreadsheets (`CONTEXT_PRD.md` L5–6)
   - Deterministic engine in shared `@nibblet/rebuild-engine` package; AI around, not inside, math (`AI_AND_INFERENCE.md`; `audit-deal.ts`)
   - Offline-first PWA with Dexie sync (`CONTEXT_PRD.md` L7; `SYNC_ARCHITECTURE_DOCUMENTATION.md`)
   - Triangulation trust model — three methods + 20% variance flag (`ESTIMATE_MODEL_V2.md`)
   - Deal-linked projects via canonical `core.deals` (`create-project-from-deal.ts`)

6. **AI role and limits:**
   - **AI does:** Text intake parsing, LLM deal audit (narrative vs budget), project insights (lender/investor narratives)
   - **Deterministic:** Engine calculations, walkthrough signal inference, heuristic audit rules
   - **Human-in-the-loop:** MCP/skill drafts require finalize in app (`CLAUDE_SKILL_MCP_DESIGN.md` L33–35)
   - **Deprecated:** Voice intake path (`AI_INTAKE_FEASIBILITY.md`)

7. **Platforms & availability:**

   | Platform | Status | Source |
   |----------|--------|--------|
   | Web PWA | Primary; `build.forvex.app`; manifest “forVEX Build” | `manifest.ts`, recontrol `.env.example` |
   | Mobile / tablet | Responsive unified app; bottom nav on mobile | `(dashboard)/layout.tsx` |
   | Legacy `/field/*` | Redirects to dashboard routes | `(field)/field/page.tsx` |
   | Offline | Dexie + sync manager | `SYNC_ARCHITECTURE_DOCUMENTATION.md` |

8. **Integration (verified):**
   - **Deal:** `create-project-from-deal`; eligible deals view; rehab assist $/sqft from Deal prefs (migration)
   - **Edge:** Rebuild event projector → property condition; “worth remembering” recollection events; `rpc_apply_latest_rebuild_estimate` consumed by Edge
   - **Post:** No direct integration in REbuild3 repo
   - **Control:** MCP tools (`forvex_preview_estimate`, `forvex_save_draft_estimate`, etc.) implemented in recontrol

9. **What it replaces (documented/implied):** Spreadsheet estimating, generic contractor bid templates — **not** explicitly named competitors in repo.

10. **Honest limitations:**
    - Execution workspace still estimate-centric in places (`PROJECT_EXECUTION_REFACTOR_PLAN.md`)
    - Catalog/SKU gaps caused mis-scoped line items — Phase 9.6 addressing (`PHASE_9_6_CATALOG_AUDIT.md`)
    - REdeal actuals → underwriting feedback loop not built (`AI_ROADMAP_IDEAS.md`)
    - Custom off-catalog lines blocked until provisional-item flow (`ESTIMATE_MODEL_V2.md`)

### User journeys

**Journey 1 — Configure the business (first-time admin)**  
- **Trigger:** New workspace needs pricing standards  
- **Steps:** Library → price books → rehab profiles (Light/Medium/Heavy rules per category)  
- **Outcome:** Team-wide estimating standards ready for field use  
- **Source:** `CONTEXT_PRD.md` L23–29

**Journey 2 — Field estimate at property**  
- **Trigger:** Under contract or inspecting; need rehab number  
- **Steps:** New Estimate → vitals → select profile → walkthrough modules (toggle severity) → review totals → save/sync  
- **Outcome:** Categorized rehab total + line-item SOW; works offline, syncs later  
- **Source:** `CONTEXT_PRD.md` L31–43

**Journey 3 — Audit before commit**  
- **Trigger:** Estimate ready; need downside check before offer/rehab budget lock  
- **Steps:** Field Action Hub → run heuristic + AI audit → review warnings/badges/score → finalize  
- **Outcome:** Audit score and badges persisted; can flow to Edge property condition  
- **Source:** `audit-deal.ts`; `auditor.ts`

### Feature inventory

| Feature name (user-facing) | What it does | Primary surface | Maturity | Source file |
|---------------------------|--------------|-----------------|----------|-------------|
| Library | Items, price books, profiles, contractors | Web (desktop) | GA | `library/page.tsx` |
| New Estimate | Start project/estimate from vitals | Web (mobile + desktop) | GA | `(dashboard)/estimates/new` |
| Module walkthrough | Room severity → line items | Web (touch-first) | GA | `(field)/field/projects/[id]/walkthrough` |
| Text intake | AI-assisted scope from description | Web | Beta | `AI_AND_INFERENCE.md` |
| Estimate triangulation | Three-method cross-check + variance | Web | Beta (Phase 9) | `ESTIMATE_MODEL_V2.md` |
| Deal audit (AI) | LLM narrative vs budget warnings | Web | GA | `audit-deal.ts` |
| Heuristic audit | Contingency vs volatility rules | Web | GA | `auditor.ts` |
| SOW | Printable scope of work | Web | GA | `sow/page.tsx` |
| Project workspace | Execution tabs post-finalize | Web (desktop) | Partial | `project-workspace.tsx` |
| Create from Deal | Link estimate to Deal record | Web | GA | `create-project-from-deal.ts` |
| Project insights | Lender/investor AI narratives | Web | GA | `generate-project-insights.ts` |
| Offline sync | Dexie queue + conflict handling | Web PWA | GA | `SYNC_ARCHITECTURE_DOCUMENTATION.md` |

### Messaging inputs

**Pain points:**
- Line-by-line data entry slows field estimating (`CONTEXT_PRD.md` L5)
- Cost overruns from unmodeled volatility/contingency (`auditor.ts` critical warnings)
- Inconsistent “what Medium rehab means” across projects (profiles solve this)

**Outcome statements:**
- Select Light/Medium/Heavy → system generates detailed SOW (`CONTEXT_PRD.md` L5–6)
- Three estimate methods cross-check with variance flag (`ESTIMATE_MODEL_V2.md` L48–52)
- Estimate offline; sync when connection returns (`CONTEXT_PRD.md` L7)

**Words/phrases used consistently:**
- Scope of Work (SOW), Rehab Profile, Price Book, Library, Light/Medium/Heavy, triangulation, finalize, recollection (“worth remembering”)

**Words/phrases to avoid:**
- REbuild, RE:build (use **forVEX Build**)
- “Two separate apps” (legacy framing; now unified responsive app)

**Proof points:**
- Phases 1–7 + `forvex-rehab-estimator` skill shipped per `CURSOR_IMPLEMENTATION_PLAN.md`
- Documented real failure case + fix plan (1860 E Deb Dr) in `ESTIMATE_MODEL_V2.md`
- **Unknown:** production customer count, accuracy vs actuals metrics

### Copy gaps vs. current website

| Current website | Repo truth | Gap |
|-----------------|------------|-----|
| “Web Dashboard + Field App (iPad/iPhone)” | Converging to one PWA; responsive layout | **Outdated split-app framing** |
| “AI audit” | AI audit + heuristic audit + triangulation | **Under-specified** |
| “Downside-aware estimating” | Accurate; triangulation + contingency warnings are the proof | Add concrete mechanism |
| No mention of Deal linkage | Create from Deal + apply estimate back to Deal | **Missing integration story** |
| No mention of execution workspace | Partially shipped post-finalize | Optional mention; mark partial |

### Sources

- `/Volumes/Lexar/REbuild3/docs/CONTEXT_PRD.md`
- `/Volumes/Lexar/REbuild3/rebuild3/app/manifest.ts`
- `/Volumes/Lexar/REbuild3/ESTIMATE_MODEL_V2.md`
- `/Volumes/Lexar/REbuild3/rebuild-PRODUCTION_ARCHITECTURE.md`
- `/Volumes/Lexar/REbuild3/rebuild3/app/actions/ai/audit-deal.ts`
- `/Volumes/Lexar/REbuild3/rebuild3/app/actions/projects/create-project-from-deal.ts`
- `/Volumes/Lexar/REbuild3/docs/SYNC_ARCHITECTURE_DOCUMENTATION.md`

---

## forVEX Edge

### Product truth

1. **One-sentence definition:** Workspace platform for real estate operators to plan, execute, and learn across the investment lifecycle — combining pipeline execution, AI coaching, market intelligence (Sense), and performance tracking in one place.

2. **Primary user:** Real estate operators and small teams (flippers, rental operators, franchise coordinators) needing a single operational surface — not generic agents/brokers (`internal_tester_overview.md`; `unified_advisor.md` references franchise operators).

3. **Job to be done:**  
   - **Before:** Context scattered across spreadsheets, chat, and single-purpose tools; no shared pipeline truth.  
   - **After:** Three streams connected — market intel, execution, performance — with AI advisors and tasks available from any view (`internal_tester_overview.md` L3–5).

4. **Top capabilities:**
   - **Sense** — market/tract intelligence, neighborhood signals (WIP)
   - **Advise** — forVEX Advisor streaming chat, debriefs, RAG knowledge pills
   - **Operate** — property pipeline, notes, checklists, activities
   - **Reflect** — daily pulse, weekly AI rollups, sentiment analytics
   - **Track** — KPIs, portfolio metrics, trends
   - **Tasks** — global drawer for actions linked to properties/threads/reflections
   - **REbar** — contextual insight cards per workspace

5. **Differentiators (documented):**
   - “Internal advisor, not generic chat” (`internal_tester_overview.md` L12–13)
   - Three-stream framing: market / execution / performance (same source)
   - Ecosystem system of record for pipeline stage (`canon.md`; `ARCHITECTURE.MD` L58–89)
   - Single forVEX Advisor with register lenses vs legacy multi-agent (`README.md` L15–18)
   - Consumes authoritative analysis from Control MCP — does not own underwriting math (`CONTRACTS.md` L11)

6. **AI role and limits:**
   - **AI does:** Advisor chat, debriefs, Reflect Deeper, weekly rollups, Track insights, Operate pipeline overview
   - **Not authoritative for:** Underwriting numbers (recontrol MCP owns writes)
   - **RAG:** pgvector knowledge pills with source attribution (`README.md` L30–33)
   - **Sense AI:** Market posture/briefings; multi-market degradation noted in GTM docs

7. **Platforms & availability:**

   | Platform | Status | Source |
   |----------|--------|--------|
   | Web | Primary; `edge.forvex.app`; Next.js Pages Router | `.env.local.example`, `README.md` |
   | Mobile | Responsive / PWA-first; dedicated mobile IA doc | `MOBILE_DESIGN_PRINCIPLES.md` |
   | Native app | Not shipped; responsive web first | `mobile-property-view-recommendations.md` |
   | Version | v0.7; README: “Production Ready – Advisors + Reflect” | `README.md` L5–6 |

8. **Integration (verified):**
   - **Deal:** Webhook `POST /api/redeal/sync`; divergence pills show Edge vs Deal sources; Sense deal-posture API consumed by Deal app
   - **Build:** Apply rebuild estimate RPC; checklist triggers on estimate changes; activity feed shows rebuild events
   - **Post:** Entity sharing UI only — “half-wired” (`REadvise_evidence_based_report.md` L51)
   - **Control:** Sense ingest/bootstrap admin links; MCP authoritative values

9. **What it replaces (documented/implied):** Operational scatter — not named CRM competitors. Positioned as downstream operating surface vs Deal’s underwriting entry.

10. **Honest limitations:**
    - Sense explicitly WIP (`internal_tester_overview.md` L9–10, L29)
    - Feature health registry lists broken/partial Sense, Operate, Track items (`FEATURE_HEALTH.md`)
    - README understates Operate/Track/Sense vs internal overview
    - REdeal being deprecated as primary mobile property surface — transition period (`mobile-property-view-recommendations.md`)
    - All workspace members see all data (Phase A — no personal/private split yet)

### User journeys

**Journey 1 — Monday morning portfolio readout**  
- **Trigger:** Weekly review; need performance snapshot  
- **Steps:** Open Track → Summary/Trends → review KPIs → optional Reflect weekly card  
- **Outcome:** Conversion, profitability, capital efficiency signals with AI layer  
- **Source:** `internal_tester_overview.md` L21–22; `track.md`

**Journey 2 — Push deal into operations**  
- **Trigger:** Deal underwritten in Deal app  
- **Steps:** Deal pushes underwriting → appears in Operate pipeline → add notes/tasks/checklists  
- **Outcome:** Property in pipeline with operational context; lifecycle stage owned by Edge  
- **Source:** `redeal-integration-setup.md`; `canon.md`

**Journey 3 — Strategic decision support**  
- **Trigger:** Stuck on deal or market question  
- **Steps:** Advise → Start Conversation → streaming chat → debrief → tasks from suggestions  
- **Outcome:** Structured debrief + actionable next steps  
- **Source:** `advise.md`; `README.md` L14–22

### Feature inventory

| Feature name (user-facing) | What it does | Primary surface | Maturity | Source file |
|---------------------------|--------------|-----------------|----------|-------------|
| Sense | Market/tract intelligence, deal posture API | Web (+ inline Operate/Advise) | Beta / WIP | `internal_tester_overview.md` L9–10 |
| Advise | forVEX Advisor chat, debriefs, knowledge pills | Web | GA | `README.md`; `advise.md` |
| Operate | Property pipeline, notes, checklists | Web | GA (partial bugs) | `operate.md` |
| Reflect | Daily pulse, weekly rollups, Reflect Deeper | Web | GA | `reflect.md`; `README.md` L24–28 |
| Track | KPIs, metrics, trends | Web | GA (partial bugs) | `track.md` |
| Tasks | Global task drawer | Web | GA | `internal_tester_overview.md` L24–25 |
| REbar | Contextual insight cards | Web | GA | `global_navigation.md` L33–43 |
| Deal sync | Ingest Deal underwriting updates | Web (API) | GA | `redeal-integration-setup.md` |
| Rebuild estimate apply | Pull latest Build estimate to property | Web (API) | GA | `apply-rebuild-estimate.ts` |
| Divergence pills | Show Edge vs Deal field differences | Web | GA | `DivergencePills.tsx` |

### Messaging inputs

**Pain points:**
- Context lost moving between strategy, execution, and review (`internal_tester_overview.md` L3–5)
- Teams need single source of truth for property work (`internal_tester_overview.md` L3)
- Market signals hard to act on without pipeline connection (Sense + Operate intent)

**Outcome statements:**
- Three streams connected in one platform (market / execution / performance) — `internal_tester_overview.md` L5
- Tasks available from any workspace without losing context — L25
- Advisor feels like internal coach, not generic chat — L12–13

**Words/phrases used consistently:**
- forVEX Edge, forVEX Advisor, Vex (Ask mode), REbar, pulse, debrief, pipeline, workspace, Sense, Operate, Reflect, Track

**Words/phrases to avoid on website:**
- RE:advise, REadvise, readvise (customer brand is **forVEX Edge**)
- “Production ready” for entire platform (README limits to Advisors + Reflect)
- “Financial advice” framing — coaching/decision support language safer

**Proof points:**
- v0.7, production URL `edge.forvex.app`
- RAG ingestion pipeline + advisor cutover documented
- **Unknown:** user counts, markets covered, Sense data coverage

### Copy gaps vs. current website

| Current website | Repo truth | Gap |
|-----------------|------------|-----|
| Duplicate `/apps/readvise` AND `/apps/edge` | Customer UI is forVEX Edge | **Pick one canonical route** |
| Workspaces listed: Sense, Advise, Operate, Reflect, Track, Tasks | Matches internal docs; README narrower | Align maturity claims |
| “Monday-morning readouts” | Track + Reflect weekly rollups support this | Accurate; cite Track/Reflect |
| “Portfolio-level truth” | Pipeline in Operate + metrics in Track; Sense WIP | **Overstates Sense maturity** |
| “Business intelligence” | Broader than BI — includes execution + coaching | OK but vague |

### Sources

- `/Volumes/Lexar/readvise/docs/user_docs/internal_tester_overview.md`
- `/Volumes/Lexar/readvise/README.md`
- `/Volumes/Lexar/readvise/CONTRACTS.md`
- `/Volumes/Lexar/readvise/docs/canon.md`
- `/Volumes/Lexar/readvise/docs/redeal-integration-setup.md`
- `/Volumes/Lexar/readvise/docs/daily/FEATURE_HEALTH.md`
- `/Volumes/Lexar/readvise/components/branding/ForvexWordmark.tsx`
- `/Volumes/Lexar/reecosystem-core/ARCHITECTURE.MD` L58–89

---

## forVEX Post

### Product truth

1. **One-sentence definition:** AI-first social content creation and scheduling platform for real estate brands — turn one content input into platform-optimized posts across Facebook, Instagram, LinkedIn, Wix, and website blog, with approval-first workflow.

2. **Primary user:** Real estate investors/marketing assistants, agents/brokers, property managers, content creators (`REPOST_PRD.md` L12–16; `USER_WORKFLOW.md` personas).

3. **Job to be done:**  
   - **Before:** Manual rewriting per platform, inconsistent brand voice, disconnected from deal/rehab/ops stories.  
   - **After:** Single Pack input → multi-platform variants → review/approve → schedule/publish; optional recollections from operational apps (`REPOST_PRD.md` L18–23).

4. **Top capabilities:**
   - **Create** — recollections, generate, review (default: recollection view)
   - **Draft** — draft editor, post composer, images, preview
   - **Organize** — packages, board, library
   - **Publish** — calendar, Instagram, Facebook scheduling
   - **Summarize** — lifecycle capstone section (nav constant)
   - **Pack/Variant model** — one content unit → per-platform deliverables
   - **Voice control** — presets + sliders, brand/investor profile
   - **Recollections** — optional grounding from Build, Deal, Edge (max 3 in drawer)
   - **Website blog** — internal publish channel (Astro blog app)

5. **Differentiators (documented):**
   - Approval-first: AI generates; human reviews (`REPOST_PRD.md` L20)
   - Pack-based multi-platform from single input (L19)
   - Ecosystem recollections vs generic content AI (L22)
   - Verb-based lifecycle nav vs generic CMS (`navigation.ts` L4–6)

6. **AI role and limits:**
   - **AI does:** Content generation, platform optimization, voice-aligned rewriting, image assignment
   - **Human:** Review, edit, approve before publish
   - **Explicit non-goals:** Offline editing, analytics dashboards, real-time co-editing (`REPOST_PRD.md` L27–35)

7. **Platforms & availability:**

   | Platform | Status | Source |
   |----------|--------|--------|
   | Web | Primary PWA-style app | `apps/web/public/manifest.json` |
   | Production URL | **Unknown / not documented** | No `post.forvex.app` in env files |
   | Blog | Astro site reading Supabase | `apps/blog/README.md` |
   | Offline | Explicitly out of scope | `REPOST_PRD.md` L31 |

8. **Integration (verified):**
   - **Build, Deal, Edge:** Recollections via `readvise.recollections` → Post drawer; UI labels still REbuild/REdeal/REadvise internally (`StrategyRecollection.tsx`)
   - **Shared auth/entitlements:** `core.workspace_entitlements` includes `repost`
   - **Edge/Deal/Build → Post:** No reverse integration (Post consumes, does not push ops data)

9. **What it replaces (documented/implied):** Manual cross-posting, generic social schedulers without RE context — competitors not named.

10. **Honest limitations:**
    - Analytics dashboards explicitly out of scope (PRD non-goals)
    - Three naming models coexist: RE:post (README), Pack/Variant (PRD), Create→Publish nav (live app)
    - Recollection UI uses internal app names — needs rebrand for public marketing
    - No dedicated section in `reecosystem-core/ARCHITECTURE.MD` beyond header mention

### User journeys

**Journey 1 — Weekly content from operations**  
- **Trigger:** Finished rehab milestone or closed deal; want social post  
- **Steps:** Create → Recollection → select Build/Deal/Edge memory → Generate → review variants  
- **Outcome:** Platform-specific drafts grounded in real work  
- **Source:** `REPOST_PRD.md` L354–377; `navigation.ts` DEFAULT_VIEWS recollection

**Journey 2 — Idea to scheduled post**  
- **Trigger:** “What should I talk about this week?”  
- **Steps:** Create → Generate (topic + voice) → Draft → edit → Publish → calendar  
- **Outcome:** Scheduled posts per platform  
- **Source:** `Idea-Generation.md`; `USER_WORKFLOW.md`

**Journey 3 — Brand voice setup (first run)**  
- **Trigger:** New workspace  
- **Steps:** Settings → investor profile + brand + templates/themes → first Pack  
- **Outcome:** Voice-aligned content generation  
- **Source:** `AI_BRAND_VOICE_PROFILE_FLOW.md`; `SETTINGS_VIEWS` in `navigation.ts`

### Feature inventory

| Feature name (user-facing) | What it does | Primary surface | Maturity | Source file |
|---------------------------|--------------|-----------------|----------|-------------|
| Recollection | Import ops memories from Deal/Build/Edge | Web | GA | `StrategyRecollection.tsx`; PRD L354–377 |
| Generate | AI content from topic/inputs | Web | GA | `REPOST_PRD.md` Pack inputs |
| Pack / Variant | Multi-platform content unit | Web | GA (PRD model) | `REPOST_PRD.md` L41–74 |
| Draft / Post editor | Edit platform content | Web | GA | `navigation.ts` DRAFT_VIEWS |
| Voice control | Presets + sliders for brand tone | Web | GA | PRD L21; brand flow doc |
| Publish calendar | Schedule posts | Web | GA | `PUBLISH_VIEWS` |
| Facebook / Instagram | Platform publish targets | Web | GA | `INTEGRATIONS.md` |
| LinkedIn | Platform publish | Web | GA | PRD L5 |
| Wix blog | Blog publishing | Web | GA | PRD L5 |
| Website blog | Internal blog channel | Web + Astro | GA | `WEBSITE_BLOG_SCHEDULING.md` |
| Organize (packages/board/library) | Content organization | Web | GA | `ORGANIZE_VIEWS` |
| Analytics | Performance metrics | — | **Out of scope** | PRD L32 |
| Offline editing | — | — | **Out of scope** | PRD L31 |

### Messaging inputs

**Pain points:**
- Rewriting same story for every platform (`REPOST_PRD.md` Pack concept)
- Maintaining authentic voice at scale (voice control L21)
- Content disconnected from real deals/rehabs (recollections L22)

**Outcome statements:**
- Single input → complete multi-platform outputs (L19)
- Approval-first: AI drafts, you approve (L20)
- “Social content creation and scheduling for your brand” (`manifest.json` L8)

**Words/phrases used consistently:**
- Pack, Variant, Recollection, Create / Draft / Organize / Publish / Summarize, voice preset, approval-first

**Words/phrases to avoid:**
- RE:post, RE:dig Studio (legacy README names)
- REdeal/REbuild/REadvise in customer-facing recollection labels (rebrand to forVEX Deal/Build/Edge)

**Proof points:**
- Comprehensive PRD (1,301 lines) indicates mature product definition
- **Unknown:** production URL, customer count, publish volume, Meta/LinkedIn app review status

### Copy gaps vs. current website

| Current website | Repo truth | Gap |
|-----------------|------------|-----|
| Homepage-only mention | Full product with PRD + live nav | **Needs `/apps/post` or `/apps/repost` detail page** |
| “Execution without effort” | Approval-first — human review required | **Overstates automation** |
| “Automated scheduling” | Scheduling exists; generation is AI-assisted not fully autonomous | Soften “autonomous” language |
| No ecosystem mention | Recollections from Deal/Build/Edge | **Missing compounding value story** |
| “Consistent presence” | Accurate | OK |

### Sources

- `/Volumes/Lexar/REpost/docs/REPOST_PRD.md`
- `/Volumes/Lexar/REpost/README.md`
- `/Volumes/Lexar/REpost/apps/web/public/manifest.json`
- `/Volumes/Lexar/REpost/apps/web/src/constants/navigation.ts`
- `/Volumes/Lexar/REpost/docs/INTEGRATIONS.md`
- `/Volumes/Lexar/REpost/docs/USER_WORKFLOW.md`
- `/Volumes/Lexar/REpost/apps/web/src/components/workspace/views/StrategyRecollection.tsx`

---

## Cross-app integration (verified only)

| From → To | What flows | Mechanism | Source |
|-----------|------------|-----------|--------|
| Deal → Edge | Underwriting payload, AI snapshots, neighborhood briefing | Push from Summary; webhook sync | `SummaryScreen.tsx`; `redeal-integration-setup.md`; `READVISE_CURRENT_ARCHITECTURE.md` |
| Deal ← Edge | Market Posture (Sense), pipeline stage display | API: deal-posture; lifecycle bar reads stage | `deal-summary.md`; `DealLifecycleBar.tsx` |
| Deal ↔ Build | Rehab estimate on deal; project from deal | Apply rebuild estimate; create-project-from-deal | `DealLifecycleBar.tsx`; `create-project-from-deal.ts` |
| Build → Edge | Rehab snapshot, audit score/badges, recollection events | Event projector; mark-recollection | `20241210000015_add_rebuild_event_projector.sql`; `mark-recollection.ts` |
| Edge → Build | Apply latest estimate to property | RPC `rpc_apply_latest_rebuild_estimate` | `apply-rebuild-estimate.ts` |
| Deal/Build/Edge → Post | Operational recollections (max 3) | `readvise.recollections` → Post drawer | `REPOST_PRD.md` L354–377 |
| All → Control | Authoritative comps, underwriting, MCP tools | `control.forvex.app/api/mcp` | `MCP_REBUILD_HANDOFF.md`; `CONTRACTS.md` |
| Shared | Property/deal identity | `core.properties`, `core.deals` | `ARCHITECTURE.MD` L101–108 |

**Not verified / aspirational:**
- Automated REdeal ↔ REbuild ↔ REadvise event pipeline (`AI_ROADMAP_IDEAS.md` — idea only)
- Post → any ops app (no reverse flow found)
- Deal → Post direct (only via recollections)

**Production URLs (documented):**

| Product | URL |
|---------|-----|
| Deal | `deal.forvex.app` |
| Build | `build.forvex.app` |
| Edge | `edge.forvex.app` |
| Control | `control.forvex.app` |
| Post | **Unknown** |

---

## Brand voice notes

### Voice attributes (from product copy patterns)

| Attribute | Evidence |
|-----------|----------|
| **Operator-first** | “Forged from real field experience” (website); Deal: “pocket underwriter”; Build: “configuration over data entry” |
| **Direct, no fluff** | Deal Settings: “Advanced Tools — For when you feel like breaking things on purpose” |
| **Trust over hype** | Analyst: “no invented numbers”; Architecture: “No hallucination-prone AI in canonical data” |
| **Honest about limits** | Edge internal overview caveats; Post approval-first; AI unavailable fallbacks |
| **Technical precision** | Four named strategies, triangulation, bounded write ownership |

### Forge vs VEX meaning

**Unknown / not documented in product repos.** Grep across `reecosystem-core`, `recontrol`, and product repos found **no** definition of “Forge” or “VEX” as brand pillars. Current homepage copy (“Forge hones our systems… VEX embeds AI-first intelligence”) appears **website-only** — requires marketing/product sign-off before reuse.

### Target audience sophistication

- **Deal:** Individual investors through franchise/multi-market operators (`initial-prd.md` L15–26)
- **Build:** Investment teams with field + back-office roles (`CONTEXT_PRD.md` L4)
- **Edge:** Real estate operators and teams (`internal_tester_overview.md` L3); Advisor prompts reference franchise operating context
- **Post:** RE professionals and marketing assistants (`REPOST_PRD.md` L12–16)

**Overall:** Assumes active investors/operators, not beginner “learn real estate” audience.

### forVEX naming convention (verified)

| Public name | Internal/repo | Customer UI evidence |
|-------------|---------------|-------------------|
| forVEX Deal | redeal-mobile | `app.json`, `ForvexDealAuthHeader.tsx` |
| forVEX Build | REbuild3 | `manifest.ts` |
| forVEX Edge | readvise | `ForvexWordmark.tsx`, auth components |
| forVEX Post | REpost | `manifest.json`, `_app.tsx` |
| forVEX Control | recontrol | README, MCP docs (admin — not in website scope table) |

---

## Open questions (remaining)

1. **Edge canonical URL:** `/apps/edge` only, deprecate `/apps/readvise`?
2. **Post detail page path:** `/apps/post` vs `/apps/repost`?
3. **Recollection UI rebrand:** Replace internal REdeal/REbuild/REadvise labels before marketing Post integrations?
4. **Legal/disclaimers:** Required AI disclaimers for VEX surfaces, audit scores, Sense market intel?
5. **REdeal deprecation:** How to message skill-first Deal without confusing existing app users?
6. **Forge tagline:** ~~Pick among sharpened variants~~ **LOCKED:** *Real deals forged the rules. VEX runs them in conversation.*
7. **Competitive copy:** ~~Validate with stakeholders~~ **LOCKED:** Agent/MCP contrast in hero subhead.
8. **reecosystem-web repo:** Where is current marketing site source for implementation?

## Resolved decisions (2026-06-06)

See [Messaging Addendum](#messaging-addendum--approved-decisions-2026-06-06) for full detail. Summary: skill-first Deal; model-agnostic MCP; AI proposes / you approve; Forge = platform; VEX = AI layer; investment operating layer; Sense = KY market intel; Track = portfolio truth; Post = express + redirect; Control = footnote only; franchise/multi-market ICP; qualitative proof only.

---

## Appendix: raw quotes

1. **Deal — pocket underwriter goal**  
   > “Let users create, run, and save high-quality deal analyses in under 60 seconds.”  
   — `/Volumes/Lexar/redeal-mobile/_startup/initial-prd.md` L8

2. **Build — configuration philosophy**  
   > “Configuration over Data Entry.” The user selects high-level quality standards (Light/Medium/Heavy), and the system generates a detailed Scope of Work (SOW) which the user then refines.  
   — `/Volumes/Lexar/REbuild3/docs/CONTEXT_PRD.md` L5–6

3. **Edge — three streams**  
   > “At a high level, REadvise connects three streams of work: market intelligence (what the data is signaling), operational execution (what the team is doing), and performance tracking (how the portfolio is performing).”  
   — `/Volumes/Lexar/readvise/docs/user_docs/internal_tester_overview.md` L5

4. **Post — approval-first mission**  
   > “AI-first content creation for real estate professionals” — RE:post enables real estate professionals to focus on strategy and approval while AI handles content generation, optimization, and publishing.  
   — `/Volumes/Lexar/REpost/docs/REPOST_PRD.md` L10

5. **Ecosystem — bundled architecture**  
   > “The system is intentionally **bundled** (shared identity + shared auth + shared data access) while preserving **bounded write ownership** per app.”  
   — `/Volumes/Lexar/reecosystem-core/ARCHITECTURE.MD` L3–4

6. **AI trust boundary (ecosystem)**  
   > “No hallucination-prone AI in canonical data”  
   — `/Volumes/Lexar/reecosystem-core/ARCHITECTURE.MD` L9

7. **Deal analyst guardrail (in-app)**  
   > “Ask me about this deal's strategies, risks, or offer guidance. I will use the calculator and scenario engine only - no invented numbers.”  
   — `/Volumes/Lexar/redeal-mobile/redeal-mobile/app/screens/intelligence/AnalystChatScreen.tsx` L66 (approx.)

---

## Messaging Addendum — Approved decisions (2026-06-06)

Product/marketing input incorporated below. Use this addendum for website rewrite; original repo research sections remain as technical reference.

---

### Platform positioning

| Term | Approved meaning | Copy guidance |
|------|------------------|---------------|
| **forVEX** | The investment operating layer for franchise and multi-market operators | Replace “operating system” — others claim OS; we are a **layer** that connects lifecycle touchpoints |
| **Forge** | The whole platform — workflows, rules, and data **forged in real operations**, sharpened across every touchpoint | Not just “built by operators” — active verb: every deal, rehab, and week in the field hones the system |
| **VEX** | Branded name for **all AI interaction** across forVEX (Deal, Build, Edge, Post) | “VEX proposes; you approve.” Not the math. Not a model vendor. |
| **Advise** | Edge **workspace** name only — advisor/coaching mode inside Edge | Do not use “Advise” as global AI brand |
| **Control** | Internal engine room (MCP, authoritative rules) | **Omit homepage.** Optional one line in “How it works” / security architecture. **No MCP URL on site yet.** |

**Approved trust pattern:** **AI proposes, you approve** — applies platform-wide (Deal saves, Build finalize, Post publish, Edge capture writes).

**Model strategy (explicit on site):** **Model-agnostic MCP layer** — proprietary business rules and data exposed as tools; ride improvements from Claude today and OpenAI, xAI, and others as they integrate skills/agents. Wording stays **vague on IP specifics** publicly (“deterministic engine, server-side rules” — not fee schedules or scoring weights).

**Primary ICP:** Franchise and multi-market operators (franchise-adjacent). Stay **qualitative** on proof — no public deal counts or customer metrics until approved.

---

### Forge + VEX — articulation (draft for copy team)

**Core tension to resolve:** “Forged” must communicate *operator-built, battle-tested, continuously sharpened* — not blacksmith metaphor cosplay.

**Favorite direction (needs sharper Forge half):**
> Real deals forged the system. VEX makes it conversational.

**✅ LOCKED (2026-06-06):**
> **Real deals forged the rules. VEX runs them in conversation.**

**Forge half — options tested (superseded by locked line above):**

| Variant | Forge emphasis |
|---------|----------------|
| A | **Every deal forges the platform.** VEX makes it conversational. |
| B | **Forged in the field, not in a lab.** VEX brings it to the conversation. |
| C | **Real operators. Real deals. A platform forged in production.** VEX is how you work it. |
| D | **The workflows are forged under pressure.** VEX is how you run them. |
| E | **forVEX is forged across the lifecycle** — offer, rehab, operate, express — **and sharpened every time you use it.** VEX is the conversational layer. |

**VEX half — consistent payload:**
- Talk to your deals, scopes, pipeline, and content in natural language
- Agents call **your** rules and **your** data — not generic ChatGPT
- You stay in control: preview, edit, approve before anything persists

**Subheads / supporting lines (not final copy):**
- *An investment operating layer for operators who run at scale.*
- *We harden the business rules. Agents do the legwork. You make the calls.*
- *Not another app racing to add AI features — infrastructure built for the agentic shift.*

---

### Competitive differentiation — “agentic MCP” (draft narrative)

**Primary frame:** vs. **point-solution apps** (spreadsheet + CRM + estimator + scheduler + chatbot).

**Secondary frame:** vs. **AI features bolted onto legacy apps** — competitors update screens every model cycle; forVEX exposes **durable logic as tools** agents can call, so capability compounds when models improve.

| They… | forVEX… |
|-------|---------|
| Embed chat in an app screen | Opens **business rules + workspace data** to agents via MCP |
| Rebuild UI when models change | **Same tools**, better agents — model-agnostic layer |
| Let the LLM guess at numbers | **Deterministic engine** runs server-side; VEX interprets and orchestrates |
| Siloed products per workflow | **Shared identity** (`core.*`) across Deal → Build → Edge → Post |
| Autonomous posting / “AI does it all” | **Approval-first** — AI proposes, you approve |

**One-sentence draft (internal):**
> forVEX is the investment operating layer where operator-forged business rules meet model-agnostic agents — so you get sharper workflows and compounding AI capability without rebuilding your stack every six months.

**Caution:** “Agentic” is industry hype — pair with concrete pattern: **Skills + MCP + server-side rules + human approval.** Avoid claiming full autonomy.

**Open for stakeholder review:** Is “vs. point solutions” enough on homepage, or lead with “vs. AI-washed legacy apps”? Recommendation: **lead lifecycle + Forge/VEX**, support with one “How we’re different” block using table above.

**✅ LOCKED (2026-06-06):** Agent/MCP contrast belongs in the **hero subhead** (below H1), not buried in a lower page block.

---

### Homepage hero — approved structure (not final polish)

| Element | Approved content / direction |
|---------|---------------------------|
| **H1** | Real deals forged the rules. VEX runs them in conversation. |
| **Subhead** | Agent/MCP contrast + investment operating layer. Draft direction below. |
| **CTAs** | Keep “See the Platform” / “Request Access” unless web team revises |

**Subhead — draft direction (for copy team to polish):**

> **✅ LOCKED:** The investment operating layer where operator-forged rules meet model-agnostic agents. VEX proposes. You approve. Models change; your logic doesn’t.

**Alternatives considered (superseded):**

- *A (contrast-forward):* forVEX is the investment operating layer for franchise and multi-market operators. Your business rules and deal data, exposed as agent tools — model-agnostic and approval-first — so capability grows with every model, not every app release.
- *C (operator-first):* Built from real deals across offer, rehab, operate, and express. forVEX opens that logic to agents via a model-agnostic layer — not another chat feature glued onto a legacy app.

---

### Product messaging — approved per app

#### forVEX Deal

| Dimension | Approved messaging |
|-----------|-------------------|
| **Hero angle** | **Talk to your deal in Claude.** |
| **Primary surface** | Claude Skill (`forvex-underwriting`) + MCP tools on Control |
| **App role** | Secondary / parity in progress — review and confirm in app when needed; **do not lead with Fast Mode, photos, or mobile app** |
| **Drop from copy** | Photos (lives on Build); “pocket app” / offline-first as hero |
| **Keep (supporting)** | Four-strategy underwriting, buy-box fit, comp/market tools via MCP |
| **Honest caveat** | Skill parity with legacy app still in progress — avoid “fully replaces app today” |

**Draft one-liner:** Underwrite in conversation — four strategies, your buy box, your data, your approval.

#### forVEX Build

| Dimension | Approved messaging |
|-----------|-------------------|
| **Hero angle** | **Describe the property in conversation** → scope and numbers materialize in Build |
| **Primary surface** | Claude Skill (`forvex-rehab-estimator`) + MCP preview/save |
| **App role** | **Review, refine, walkthrough, triangulate, finalize** — especially iPad/field walkthrough and audit UI |
| **Emphasis** | Configuration over data entry; approval before finalize |

**Draft one-liner:** Tell Build what you’re looking at. Review the scope before you commit.

#### forVEX Edge

| Dimension | Approved messaging |
|-----------|-------------------|
| **Hero angle** | **The operator command center** — pipeline, market context, portfolio performance |
| **Primary surface** | Web app (Edge workspaces) |
| **Conversational layer** | Capture and updates on the go via `readvise-capture` skill (notes, tasks, pulse) — **accessible in conversation, not replacing the app** |
| **Sense** | **Market intel** — tract/neighborhood/macro; **live for Kentucky markets** |
| **Track** | **Portfolio truth** — KPIs, conversion, capital efficiency (Operate has property summary, not portfolio claim) |
| **Advise workspace** | forVEX Advisor / coaching — use **Advise** name here only |

**Draft one-liner:** Run the business in Edge. Update it from anywhere VEX listens.

#### forVEX Post

| Dimension | Approved messaging |
|-----------|-------------------|
| **Lifecycle position** | **Express step** — parallel to and after operational work; ground posts in recollections from Deal/Build/Edge |
| **URL** | Today: [`repost.reecosystem.app`](https://repost.reecosystem.app/workspace?section=create&view=generate). Target: **`post.forvex.app`** with **redirect** from legacy |
| **Hero angle** | Turn what you did into what you publish — approval-first, multi-platform |
| **Pattern** | AI proposes drafts; you approve; then schedule/publish |

**Draft one-liner:** When the work is worth sharing, Post turns operational memory into brand presence.

---

### Updated lifecycle map (approved)

```
Market context (Sense, KY) ──► Deal (Claude: underwrite) ──► Build (Claude: scope → app: refine)
                                      │                              │
                                      └──────────► Edge (operate · track · reflect)
                                                         │
                         recollections (parallel) ◄──────┴──────► Post (express · publish)
```

**Handoffs unchanged technically** (`core.*` IDs, MCP writes, recollections). **Copy change:** lead each stage with conversational entry where Skills exist; app as review/finalize surface.

---

### Homepage pillars — suggested revision

| Current pillar | Suggested revision |
|----------------|-------------------|
| Built by Operators | **Forged in production** — every lifecycle touchpoint sharpens the platform |
| Real Workflows, Not Templates | **Operator workflows, exposed as agent tools** — not generic prompts |
| Context That Travels | **Shared identity across the operating layer** — Deal, Build, Edge, Post |
| AI as Leverage | **VEX proposes. You approve.** Model-agnostic agents on operator-forged rules |

**Retire:** “Operating system” hero language.

**Lifecycle cards — headline direction:**

| App | Headline direction | Subhead direction |
|-----|-------------------|-------------------|
| Deal | Talk to your deal | Underwrite in Claude — four strategies, your rules |
| Build | Describe the rehab | Conversation to scope; app to refine and audit |
| Edge | Run the operation | Market intel (Sense) · execution (Operate) · portfolio truth (Track) |
| Post | Express the work | From recollection to published — you approve every word |

---

### forVEX Control — “How it works” footnote (optional)

> forVEX runs on a shared data layer with server-side business rules. Deterministic calculations and workspace data are exposed to AI agents through a model-agnostic tool interface — so agents orchestrate, but your rules and approval gates persist regardless of which model you use.

Do **not** include Control URL, admin login, or MCP connector setup on marketing site until decision #17 is resolved.

---

### What changed vs. original research doc

| Topic | Original research | Approved (2026-06-06) |
|-------|-------------------|------------------------|
| Deal primary story | Mobile/web underwriting app | Claude Skill + MCP first |
| Deal photos | User-visible feature | Omit — Build owns field capture |
| Edge Sense | WIP, vague | Market intel; **live Kentucky** |
| Portfolio truth | Implied Sense/Edge broadly | **Track only** |
| Post URL | Unknown | `repost.reecosystem.app` → redirect to `post.forvex.app` |
| Post lifecycle | End-of-funnel marketing | **Express** step, parallel to lifecycle |
| Forge/VEX | Undocumented | Approved definitions above |
| OS metaphor | Flagged as unverified | **Investment operating layer** |
| Control | External product? | Internal; footnote only |
| Proof | Unknown | Stay qualitative |
| Competition | Not documented | Point solutions + agentic MCP narrative (draft) |

