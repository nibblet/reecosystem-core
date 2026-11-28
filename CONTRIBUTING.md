# Contributing to ForVEX (multi-app workspace)

This workspace contains multiple apps that share one Supabase/Postgres backend. Changes must preserve:
- canonical identity spines in Core
- bounded write ownership per app
- workspace isolation via RLS

If you break these, you will ship a bundle that is basically a monolith with sync bugs.

---

## Core principles

### 1) Canonical identity lives in Core
- `core.properties.id` is the canonical property ID
- `core.deals.id` is the canonical deal lifecycle ID

Apps must not create “shadow canonical” property/deal tables.

### 2) Bounded ownership (no cross-app writes)
- Core: identity + workspace/entitlement + shared cache
- REdeal: underwriting (`redeal.*`)
- REbuild: rehab/audit (`rebuild.*`)
- REadvise: pipeline/advisors/Sense (`readvise.*`)

**Rule:** An app may not write to another app’s schema.

### 3) Workspace isolation is non-negotiable
Any table containing `workspace_id` must have:
- RLS enabled
- policies using existing Core membership helpers:
  - read: `core.is_workspace_member(workspace_id)`
  - write: `core.has_write_access(workspace_id)`

Do not invent new auth models. Do not ship tables with workspace_id and no RLS.

---

## Address normalization rules

All property creators must use the shared helper:

`normalizeAddress(address_line1, city, state, zip)`

Output MUST be:
`ADDRESS_LINE1 CITY STATE ZIP` (uppercase, single spaces, no commas, no “USA”)

If you introduce a new normalization variant in one app, you will create duplicates in `core.properties`. Don’t.

---

## Adding / changing database schema

### Do not invent names
Schema files are the source of truth. Quote table/column names exactly.

### Migration checklist
For each new/changed table or column:
1) Add migration SQL in the appropriate repo location.
2) If table has `workspace_id`:
   - enable RLS
   - add policies (read/write)
3) Add indexes for high-cardinality query paths.
4) Add backfill scripts if you change canonical linking behavior.
5) Add verification queries.

### Core schema changes are conservative
Core is for shared spines and minimal shared fields. Do not dump app-specific guts into Core.

If a field is:
- volatile / provider-derived (beds/baths/sqft, etc.) → belongs in cache/facts layer
- workflow-specific (rehab line items, underwriting assumptions) → belongs in app schema

---

## Cross-app reads

Preferred pattern:
- Use canonical IDs and stable views.
- If Redeal needs to read Readvise overlays, add a **view** in the appropriate schema rather than wiring direct table writes/joins everywhere.

Avoid:
- Redeal code joining directly into `readvise.*` tables for filtering/ownership reasons.
- Rebuild writing underwriting or pipeline status.

---

## Offline sync rules

### Clients may create local IDs offline
But must resolve to canonical Core IDs on sync:
- upsert `core.properties` by `(workspace_id, normalized_address)`
- persist `core_property_id`
- create `core.deals` when deal lifecycle starts; persist `core_deal_id`

### Sync must not bypass RLS
RPC apply-ops must enforce workspace constraints and must not act as a hidden service role.

---

## Property classification (bundle safety)
If one app creates properties that shouldn’t show up in another app by default:
- classification must live in Core (e.g., `is_rental`, `property_type`)
- consuming apps filter using Core fields
- do not couple filters to another schema

---

## Pull request expectations
A PR that touches DB/app identity must include:
- migration SQL
- RLS policies
- verification queries
- app code updates (resolve + canonical IDs)
- brief note in the PR description explaining ownership boundaries

If you can’t explain “who writes this and why,” you don’t understand the change well enough to merge it.
