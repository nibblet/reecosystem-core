# ForVEX architecture

This repository is a multi-app workspace for **ForVEX** (forVEX Deal, Build, Edge, Post). It contains multiple apps that share a single Supabase/Postgres backend. Database schemas still use historical names such as `redeal.*` and `readvise.*`; this document uses product names where it helps readers. The system is intentionally **bundled** (shared identity + shared auth + shared data access) while preserving **bounded write ownership** per app.

Primary goals:
- **Speed to revenue**
- **Production-safe architecture**
- **Low cross-app coupling**
- **No hallucination-prone AI in canonical data**

---

## Apps

### forVEX Deal (underwriting; `redeal.*`)
**What it does**
- Deal intake and underwriting workflows (offers, assumptions, analysis).
- Often the primary entry point for “I’m going to buy this” decisions.

**Local/offline**
- iOS app with local SQLite + polling sync.

**Domain ownership**
- Owns underwriting domain tables in `redeal.*`.
- Creates canonical identity rows in Core (property + deal lifecycle) when underwriting begins.

**Writes**
- Writes to:
  - `core.properties` (identity spine) via resolve/upsert
  - `core.deals` (lifecycle spine) via create/insert
  - `redeal.properties` (underwriting overlay) linking to canonical IDs
  - `redeal.deals` (underwriting record) linking to canonical IDs

---

### forVEX Build (rehab / audit; `rebuild.*`)
**What it does**
- Rehab scope, audits, estimates, line items, field workflows.

**Local/offline**
- PWA with Dexie (IndexedDB) + sync.

**Sync**
- v2 writes via RPC apply-ops.
- pulls via PostgREST delta queries.

**Domain ownership**
- Owns rehab/audit domain tables in `rebuild.*`.

**Writes**
- Writes to:
  - `rebuild.*` tables only (domain data)
  - May resolve/upsert `core.properties` for canonical identity
- Must persist `core_property_id` on all property-scoped rebuild records.

---

### forVEX Edge (market memory, advisors, Sense; `readvise.*`)
**What it does**
REadvise manages a **property pipeline** and associated advisory workflows. It is not just “market intel” — it’s the system for:
- Ingesting and curating potential opportunities (including rentals and non-flip assets)
- Running a structured “market memory” pipeline over properties
- Storing and generating overlays/annotations/recommendations on properties
- Associating properties with advisors/agents (human workflows)
- Capturing canonical observation/signal data via `Sense_*` tables

**Key concept: Readvise owns pipeline state + advisor workflows, not canonical identity.**
Readvise can create new properties, but canonical property identity is always Core.

**Canonical data**
- `Sense_*` tables in `readvise.*` are canonical sources for signals/observations.
- Do not create “pseudo-sense” tables in other schemas.

**Domain ownership**
- Owns `readvise.*` including:
  - pipeline tables and property overlays
  - advisor-related tables and workflows
  - Sense tables (canonical signals/observations)

**Writes**
- Writes to:
  - `readvise.*` tables (pipeline + overlays + advisors + Sense)
  - May resolve/upsert `core.properties` when:
    - creating a property in the pipeline
    - address becomes resolvable for an existing pipeline property
- Must set `readvise.readvise_properties.canonical_property_id` whenever resolvable.

**Important**
Readvise pipeline properties may include rentals and other asset types that should not automatically appear in Redeal underwriting lists. This is handled by shared Core classification fields (see below).

---

## Backend: Schemas & Canonical Spines

### Core (Canonical identity + workspace + entitlement)
Core owns:
- canonical identity spines shared by all apps
- workspace model and membership/entitlements
- shared security patterns used by RLS

#### Canonical identity spines
- `core.properties` — canonical property identity per workspace  
  **Primary key**: `core.properties.id`  
  **Uniqueness**: `(workspace_id, normalized_address)`

- `core.deals` — canonical deal lifecycle per workspace  
  **Primary key**: `core.deals.id`  
  **Links**: `core.deals.property_id -> core.properties.id`

> Rule: Apps may create/update core identity rows only through deterministic “resolve” logic. Apps do not “own” core identity.

#### Workspace + entitlement model (high-level)
- Every row in bundled app domains is **workspace-scoped** using `workspace_id`.
- Access is controlled via Core membership patterns (RLS).
- Standard capability tiers:
  - workspace member: read access
  - workspace editor/owner: write access
- RLS policies must use existing Core helpers (do not invent new auth models).

> Rule: Treat Core as the only place to define “who can see/write workspace data.”

---

## Canonical IDs & Cross-App Linking

### Canonical property reference
All apps converge on:
- `core_property_id = core.properties.id`

App domain tables keep their own IDs but must link to canonical:
- `redeal.properties.canonical_property_id -> core.properties.id`
- `readvise.readvise_properties.canonical_property_id -> core.properties.id`
- Rebuild property-scoped tables store `core_property_id -> core.properties.id`

### Canonical deal reference
All apps converge on:
- `core_deal_id = core.deals.id`

REdeal underwriting tables link to canonical deal lifecycle:
- `redeal.deals.canonical_deal_id -> core.deals.id`

> Rule: Cross-app reads join on canonical IDs. Cross-app writes are NOT allowed.

---

## Address Normalization (Critical)

### Canonical `normalized_address`
All creators of properties MUST compute:
`normalized_address = normalizeAddress(address_line1, city, state, zip)`

Strict rules:
- Remove commas from address_line1
- Trim each component
- Collapse internal whitespace to single spaces
- Uppercase final string
- Format: `ADDRESS_LINE1 CITY STATE ZIP`
- Never append `USA`, never duplicate segments

This is required because `core.properties` de-duplicates by `(workspace_id, normalized_address)`.

**Do not invent other normalization.** Enhancements (RD vs ROAD, etc.) must be implemented consistently across apps and rolled out carefully.

---

## Property Classification (Bundle Safety)

Readvise may create active pipeline properties that are rentals or otherwise not underwriting candidates.

Core must provide minimal shared classification fields so apps can filter without coupling:
- `core.properties.is_rental` (boolean)
- `core.properties.property_type` (text)

**Default REdeal list behavior**
- show only non-rentals: `is_rental = false`
- optionally restrict to `property_type = 'FLIP'` if product needs require

**Rule:** Do not join into `readvise.*` from Redeal to filter properties. Filtering must happen using Core-owned classification fields.

---

## Bounded Write Ownership (Non-Negotiable)

Bundled does not mean free-for-all writes.

### Core owns
- Canonical identity spines (`core.properties`, `core.deals`)
- Workspace membership & entitlement patterns used by RLS
- Shared caching tables

### REdeal owns
- Underwriting domain (`redeal.*`)

### REbuild owns
- Rehab/audit domain (`rebuild.*`)

### REadvise owns
- Pipeline + advisors + overlays + Sense (`readvise.*`, especially `Sense_*`)

**Rule:** An app may READ other app schemas only through stable views where needed.  
**Rule:** An app must never WRITE into another app’s schema.

### Operator surfaces

Phones are clients of the owners above. They are not a fourth schema owner.

- **Readvise web and readvise-ios** use the Readvise API. They may write pipeline stage, task status, pulse, and investor preferences — all `readvise.*`. They display a saved underwriting record; they do not compute one and they do not speak MCP.
- **forvex-underwrite** calls recontrol `/api/operate/*`, the REST twin of the MCP tools. The server resolves inputs and persists the analysis. A vendored engine may recompute for slider display only from the server’s `effective_input`.

Eyes / hands / brain still names the agent stack (bots act, recontrol decides numbers and IDs, Readvise shows the record). These apps are operator surfaces on those same doors.

---

## RLS & Workspace Isolation

All workspace-scoped tables contain `workspace_id` and MUST:
- have RLS enabled
- have policies enforcing workspace isolation using existing Core membership helpers
  - read: workspace members
  - write: workspace editors/owners

Service role bypass is allowed only in server-side contexts (edge/prefill), never client-side.

---

## Property API Caching (Realie) — Cache-first, TTL-based

Provider calls (e.g., Realie) must not be performed repeatedly by clients.

Core owns caching:
- `core.property_api_cache`
  - keyed by `(workspace_id, property_id, provider, data_type)`
  - stores raw response JSON and timestamps
  - TTL-based freshness (`expires_at`)
  - concurrency-safe refresh (single winner per key)

Canonical property identity remains `core.properties.id` + address. Realie v3 adds optional `core.properties.realie_parcel_id` (never persist Realie `_id`). Cache rows may be **flat** (legacy / foreclosure-filter searches) or **nested** (account opt-in v3); readers must accept both. Do not bulk-rewrite historical `response_json`.

**Client behavior**
- Cache-first reads from `core.property_api_cache`
- If expired/missing: trigger a refresh via server-side pathway (edge/prefill) or lease mechanism
- Clients do NOT write provider payloads directly unless explicitly designed (prefer service writes)

---

## Offline Sync Expectations

### REdeal (SQLite)
- May create properties/deals offline with local IDs.
- On sync / on create:
  1) resolve/upsert `core.properties` by `(workspace_id, normalized_address)`
  2) persist `core_property_id` locally
  3) create `core.deals` and persist `core_deal_id`
  4) write `redeal.*` rows linking to canonical IDs

### REbuild (Dexie + RPC apply-ops)
- Must include `core_property_id` on all property-scoped records.
- Must resolve missing `core_property_id` before generating/applying ops.
- RPC must not bypass workspace isolation.

### REadvise
- Pipeline may start with incomplete addresses.
- Only when address is resolvable:
  - compute `normalized_address`
  - resolve/upsert `core.properties`
  - set `canonical_property_id`

---

## Do/Don’t for Cursor Agents

### DO
- Use canonical IDs for cross-app joins (`core_property_id`, `core_deal_id`)
- Keep write ownership bounded
- Add stable views for cross-app reads when needed
- Use existing Core membership helpers for RLS policies
- Keep Readvise pipeline/advisor logic in `readvise.*`

### DON’T
- Don’t invent table or column names
- Don’t write into another app’s schema
- Don’t introduce new auth models
- Don’t create pseudo-sense tables outside `Sense_*`
- Don’t normalize addresses differently per app

---

## Success Criteria (Milestone 1 baseline)
- Every app references shared canonical `core.properties.id` and `core.deals.id`
- Workspace isolation enforced via RLS across all workspace-scoped tables
- Realie calls cached (TTL), cache-first reads, concurrency-safe refresh
- Bundling reduces coupling, does not increase it



---

## Property ownership matrix

### Canonical identity spine: `core.properties`

| Field | Writer(s) | Source of truth | Notes / Rules |
|-------|-----------|-----------------|---------------|
| `workspace_id` | All creators (resolver) | Core | Always set; used for RLS + uniqueness. |
| `address_line1` | Resolver (Redeal/Readvise/Rebuild) | Core | Written via resolve/upsert; should reflect normalized address components. |
| `city` | Resolver | Core | Same as above. |
| `state` | Resolver | Core | Same as above. |
| `zip` | Resolver | Core | Same as above. |
| `normalized_address` | Resolver | Core | Deterministic: `normalizeAddress(...)`. Uniqueness key `(workspace_id, normalized_address)`. |
| `latitude` | Best-effort writers | Core | Optional; last-good-write wins. Prefer higher-quality source if available. |
| `longitude` | Best-effort writers | Core | Optional; last-good-write wins. |
| `address_hash` | Best-effort writers | Core | Optional; if used, keep consistent and derived from address. |
| `property_type` | Readvise primary, Redeal default | Readvise | Readvise sets from pipeline (`readvise.readvise_properties.property_type`). Redeal can default to `'FLIP'` on create. Redeal must not override Readvise changes. |
| `is_rental` | Readvise primary, Redeal default | Readvise | Readvise sets from pipeline (`readvise.readvise_properties.is_rental`). Redeal can default `false` on create. Redeal must not flip true → false. |
| `pipeline_stage` | Readvise only | Readvise | Projection of `upper(readvise.readvise_properties.new_status)`. Redeal/Rebuild read-only. |
| `created_at` | DB | Core | DB-owned. |
| `updated_at` | DB | Core | DB-owned (trigger). |

### Underwriting overlay: `redeal.properties`

| Field | Writer(s) | Source of truth | Notes / Rules |
|-------|-----------|-----------------|---------------|
| `workspace_id` | Redeal | Redeal | Always set. |
| `address_line1`, `city`, `state`, `zip`, `normalized_address` | Redeal | Redeal | Kept for compatibility/UX; must be consistent with Core resolution logic. |
| `latitude`, `longitude`, `address_hash` | Redeal | Redeal | Can be used to improve core on create; redeal is not canonical. |
| `tract_id`, `market_id`, `neighborhood_id` | Redeal | Redeal | Underwriting/context overlays. |
| `sense_resolved_at`, `sense_resolution_json` | Redeal | Redeal | Underwriting or enrichment metadata. |
| `canonical_property_id` | Redeal (via resolver) | Core | Must always point to `core.properties.id`. Required for cross-app joins. |
| `created_at`, `updated_at` | DB | Redeal | DB-owned. |

### Pipeline + advisors overlay: `readvise.readvise_properties`

| Field | Writer(s) | Source of truth | Notes / Rules |
|-------|-----------|-----------------|---------------|
| `workspace_id` | Readvise | Readvise | Always set. |
| `property_type` | Readvise | Readvise | Check-constrained to FLIP/RENTAL. |
| `new_status` | Readvise | Readvise | Pipeline stage (`DealLifecycleStatus`, `SKILL_SYSTEM_CONTRACT` §3.4): LEAD, OFFER, UNDER_CONTRACT, INVENTORY, REHAB, LISTED, PENDING, SOLD, FOLLOW_UP, LOST. `FOLLOW_UP` is a paused exit and requires a follow-up reason; `LOST` is terminal and requires a lost reason. |
| `is_rental` | Readvise | Readvise | Rental classification. |
| `address`, `city`, `state`, `zip`, `normalized_address` | Readvise | Readvise | Address pipeline data; normalization trigger exists; canonical identity still in Core. |
| `canonical_property_id` | Readvise (via resolver/trigger) | Core | Must reference `core.properties.id` when resolvable. |
| (all other pipeline/advisor fields) | Readvise | Readvise | e.g. lead dates, tags, notes, visibility. Readvise owns. |

---

## Deal ownership matrix

### Canonical lifecycle spine: `core.deals`

| Field | Writer(s) | Source of truth | Notes / Rules |
|-------|-----------|-----------------|---------------|
| `workspace_id` | Deal creator (usually Redeal) | Core | Always set. |
| `property_id` | Deal creator | Core | Must reference `core.properties.id`. |
| `status` | Redeal primary | Core | Deal lifecycle state (not pipeline stage). Keep semantic clean. Default `'new'` until real transitions are implemented. |
| `archived_at` | Redeal (maybe Rebuild later) | Core | Archiving is lifecycle; should be consistent across apps. |
| `archived_by` | Redeal (maybe Rebuild later) | Core | Same. |
| `created_at`, `updated_at` | DB | Core | DB-owned. |

### Underwriting truth: `redeal.deals`

| Field | Writer(s) | Source of truth | Notes / Rules |
|-------|-----------|-----------------|---------------|
| `workspace_id` | Redeal | Redeal | Always set. |
| `property_id` | Redeal | Redeal | References `redeal.properties.id` (local overlay). |
| `canonical_deal_id` | Redeal (via core create) | Core | Must reference `core.deals.id`. |
| `status` | Redeal | Redeal | Underwriting workflow status (can differ from core lifecycle). |
| `archived_at`, `archived_by` | Redeal | Redeal | Local archive; should usually mirror Core archive when used. |
| Underwriting assumptions (e.g. `arv`, `purchase_price`, `offer_price`, rehab fields) | Redeal | Redeal | Redeal-only writes; other apps read-only via views if needed. |
| Bedrooms/size assumptions (e.g. `beds`, `baths`, `square_feet`) | Redeal | Redeal | Underwriting assumptions, not provider facts. |
| `created_at`, `updated_at` | DB | Redeal | DB-owned. |

---

## Display rules (from the matrices)

Use these to avoid UI confusion.

**In Redeal "Deals list"**

- **Stage badge** → `core.properties.pipeline_stage` (projection of Readvise `new_status`).
- **Rental filter** → `core.properties.is_rental = false` by default (plus `property_type` as needed).
- Keep underwriting helper text (spread/assignment) separate when it's underwriting-derived.

**In Deal Summary header**

When showing "status", label explicitly as either:

- **Stage (pipeline)** → from `core.properties.pipeline_stage`
- **Deal lifecycle** → from `core.deals.status` (once meaningful)