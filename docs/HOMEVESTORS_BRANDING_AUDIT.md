# HomeVestors Branding Compliance Audit

**Date:** 2026-08-11  
**Scope:** All forVEX workspace apps  
**Policy:** Affiliation/branding signals only (competitor-intel market-data mentions kept)  
**Phase:** Inventory complete; remediation waves **R1–R5 applied 2026-08-11** (R6 history purge deferred)

### Remediation status (2026-08-11)

| Wave | Status | Notes |
|---|---|---|
| R1 Themes | Done | `homevestors` → `slate-gold` / “Slate & Gold” in REpost, redeal-mobile; REbuild3 condition updated; localStorage migration in REpost ThemeContext |
| R2 Prompts | Done | readvise advisors/voice/unified prompts; forvex-train `lib/prompts/*` rebranded to forVEX Train |
| R3 Marketplace/READMEs | Done | Marketplace defaults, workflows Flip/Rental, public HTML, readvise + crg-dma READMEs |
| R4 Emails/fixtures | Done | recontrol `IMPERSONATE_EMAIL` env/fallback; redeal `temp_log.md` removed; fixtures neutralized |
| R5 Docs | Done | recontrol Wave-1 docs, REpost color docs, reecosystem-core website copy research |
| R6 History | Deferred | Keep private; no filter-repo unless mandated |

## Executive summary

Corporate previously flagged **public** exposure on `recontrol` and `reecosystem-core`. Both remotes are **private** now (0 forks). Working-tree affiliation in those two is relatively light; the larger product risk sits in **readvise**, **forvex-train**, and **theme branding** in REpost / redeal-mobile.

| Severity | Meaning | Approx. finding groups |
|---|---|---|
| **P0** | User-visible product surface (UI themes, shipped AI prompts, public HTML) | ~8 groups |
| **P1** | Affiliation in committed source (scripts, fixtures, defaults, “our company” framing) | ~10 groups |
| **P2** | Docs, READMEs, git history, GitHub metadata | ~12 groups |
| **P3 / Keep** | Competitor intel, local machine paths, vendor noise | noted below |

**Top risks to remediate first**

1. **Theme id `homevestors` / “HomeVestors Brand”** in REpost + redeal-mobile (and REbuild3 theme-id branch).
2. **Advisor / voice / train prompts** that cast forVEX as a HomeVestors coach/mentor/training system (readvise + forvex-train).
3. **Marketplace defaults & workflow names** (“Homevestors supplied opportunity”, “HomeVestors Flip/Rental”).
4. **Hardcoded `@homevestors.com` emails** and git author `Homevestors <…>` in history (esp. formerly public recontrol).
5. **README / product copy** claiming “Private HomeVestors project” or Ad Council affiliation.

---

## Remote hygiene checklist

| Repo | GitHub | Private | Description | Homepage | Forks |
|---|---|---|---|---|---|
| recontrol | `nibblet/REcontrol` | yes | empty | `https://r-econtrol.vercel.app` | 0 |
| reecosystem-core | `nibblet/reecosystem-core` | yes | empty | empty | 0 |
| REpost | `nibblet/REpost` | yes | Social Media Posting | `https://r-epost-web.vercel.app` | — |
| redeal-mobile | `nibblet/redeal-mobile` | yes | empty | `https://redeal-mobile.vercel.app` | — |
| REbuild3 | `nibblet/rebuild3` | yes | Rehab Estimator | `https://rebuild3.vercel.app` | — |
| readvise | `nibblet/REadvise` | yes | empty | `https://r-eadvise.vercel.app` | — |
| forvex-train | `nibblet/forvex-train` | yes | Sales Training App | `https://forvex-train.vercel.app` | — |
| crg-dma | `nibblet/crg-dma` | yes | empty | empty | — |

**Actions:** Keep all private. Avoid brand language in GitHub description/topics if any are added later. Empty descriptions are fine.

### Git history notes (Wave 1 depth)

**recontrol** — `git log -S'homevestors'` hits multiple commits. Notable:

- Commit authors often `Homevestors <homevestors@Homevestorss-MacBook-Air-2.local>` (machine/user identity leak).
- Scripts introducing `IMPERSONATE_EMAIL = 'paul.cobb@homevestors.com'`.
- Historical docs (e.g. AVM research) with `paul.cobb@homevestors.com` and prose tying AVMs to “HomeVestors operates in…”.

**reecosystem-core** — pickaxe for `homevestors` / `HomeVestors` / `We Buy Ugly` returned **no history commits** in this clone; current-tree hits are limited to website copy research.

**Recommendation for history:** Keep repos private. Do **not** run `filter-repo`/BFG unless corporate explicitly requires history purge; that is a separate approved ops project (rewrites SHAs, breaks clones).

---

## Findings table

### Wave 1 — Formerly public

| Severity | Repo | Path / area | Type | Recommendation |
|---|---|---|---|---|
| P1 | recontrol | `scripts/backtest-fallback.ts`, `scripts/batch-comp-review.ts`, `scripts/compare-chatarv.ts` | Hardcoded `paul.cobb@homevestors.com` | Use env var / placeholder (`operator@example.com`) |
| P2 | recontrol | `docs/COMP_V3_SIGNALS_AND_REFINEMENT.md` | Doc: “HomeVestors' buy-box” | Rephrase to “distressed / franchisee buy-box” or “operator buy-box” |
| P2 | recontrol | `docs/TARGETING_OPERATING_MODEL.md` | Doc: “HomeVestors brand/compliance” | Rephrase to generic brand/compliance gates |
| P2 | recontrol | git history + commit author | Author name/email + removed doc prose | Keep private; optional history purge only if required |
| P2 | reecosystem-core | `docs/FORVEX_WEBSITE_COPY_RESEARCH_2026-06-06.md` | ICP: “HomeVestors operators / adjacent” | Soften to “franchise / multi-market operators”; drop brand name |
| — | reecosystem-core | remote | Already private, empty description | Maintain |

### Wave 2 — Theme / product branding

| Severity | Repo | Path / area | Type | Recommendation |
|---|---|---|---|---|
| **P0** | REpost | `apps/web/src/lib/themes.ts` | Theme id `homevestors`, name `"HomeVestors Brand"` | Rename id → neutral (e.g. `slate-gold`); display name → “Slate & Gold” (keep palette) |
| **P0** | REpost | `apps/web/src/components/ThemeSelector.tsx` | Copy: “Perfect when HomeVestors branding is essential” | Neutral marketing copy |
| **P0** | REpost | `apps/web/src/styles/globals.css` | `[data-theme="homevestors"]` + comments | Rename attribute in lockstep with theme id; migrate stored prefs |
| P1 | REpost | `scripts/test-auto-draft-optimizations.ts` | `brandName: "HomeVestors"` | Use `forVEX` / fictional brand |
| P2 | REpost | `docs/COLOR_*.md`, `docs/AI_ROADMAP_SUGGESTIONS.md`, `docs/GENERATE_PREVIEW_WORKFLOW.md` | Extensive brand theme docs / example brandName | Neutralize or archive as internal design history |
| **P0** | redeal-mobile | `redeal-mobile/app/theme/themes.ts` | Same theme id/name pattern | Same rename as REpost |
| P1 | redeal-mobile | `temp_log.md` | Committed auth logs with `@homevestors.com` | Delete from tree; ensure gitignored |
| P2 | redeal-mobile | `skills/ROADMAP.md`, `_startup/initial-prd.md` | “HomeVestors” ops / Claude workspace | Soften affiliation language |
| P1 | REbuild3 | `rebuild3/components/theme-customizer.tsx` | Branches on `themeId === 'homevestors'` | Follow theme rename; update condition |
| P2 | REbuild3 | `scripts/catalog_audit_by_workspace.sql` | Comment: “HomeVestors / production workspace” | Neutral comment |

### Wave 3 — readvise / forvex-train / crg-dma

| Severity | Repo | Path / area | Type | Recommendation |
|---|---|---|---|---|
| **P0** | readvise | `advisors/*.md`, `lib/prompts/{business,franchise,unified}_advisor.md`, `lib/advisor-prompts.ts`, voice prompts | Product AI: “seasoned HomeVestors coach/mentor” | Rebrand personas to forVEX / franchise-operator coaches; drop HV brand |
| **P0** | readvise | `lib/operate/workflow/definitions/{flip,rental}.ts` | Workflow names `HomeVestors Flip/Rental` | Rename to Flip / Rental (or forVEX Flip) |
| **P0** | readvise | `components/operate/marketplace/MarketplaceIntakePanel.tsx` | UI placeholder deal terms | Neutral placeholder (“Seller-supplied opportunity…”) |
| **P0** | readvise | `public/marketplace-docs/state-attorney-and-wholesale-lists.html` | “Audience: HomeVestors franchisees…” | “Franchise operators / advisors…” |
| P1 | readvise | `scripts/marketplace/*`, `lib/marketplace/parsePaste.ts`, tests | Default terms “Homevestors supplied opportunity…” | Neutral default string + update tests |
| P1 | readvise | `README.md` | “Private HomeVestors project” | “Private forVEX project” |
| P1 | readvise | `docs/plans/workspace_planning/remind_users_rows.json`, email comments | `@homevestors.com` fixtures | Synthetic emails |
| P1 | readvise | `scripts/consolidate-competitor-aliases.ts`, `docs/COMPETITOR_ALIAS_RECOMMENDATIONS.md`, extractor comments | “Our company” framing | Keep exclusion if needed; rephrase to “excluded brand / not tracked as competitor” without claiming ownership |
| P1 | readvise | `lib/operate` fee docs / buy-box plans | “HomeVestors transaction fee schedule” | Rename to workspace/franchise fee schedule if still accurate as data; else generalize |
| P2 | readvise | weekly-runs, guides with `/Users/HomeVestors/…`, rumination | Docs / machine paths | Soften or leave as P3 noise |
| P2 | readvise | git history | Many commits with emails / prompts | Keep private; purge only if required |
| **P0** | forvex-train | `lib/prompts/*` (coach, drill, seller, scoring, session-summary, etc.) | Shipped training prompts branded HomeVestors | Rephrase to forVEX Train / generic investor-buyer training |
| P1 | forvex-train | `doc/PRODUCT-ROADMAP.md`, nightshift plans, outputs | Product framed as HV franchisee training | forVEX Train positioning |
| Keep | forvex-train | Competing-offer examples citing “We Buy Ugly Houses” as **other** buyer | Competitor scenario | Keep under policy B; ensure forVEX is not cast as HV |
| P2 | crg-dma | `README.md` | “Louisville HomeVestors Ad Council” | Rephrase to Louisville Ad Council / operator co-op without HV brand |

---

## Keep list (competitor intel / noise)

These are **not** remediations under policy B, unless they also claim “we are HomeVestors.”

| Repo | Path | Rationale |
|---|---|---|
| readvise | `lib/readvise/competitorExtractor.ts` alias list | Market entity recognition; keep aliases |
| readvise | Market memory / competitive prompts that **exclude** HV from competitor digests | Operational filter; **rewrite “our company”** comments (P1 above) but filtering can remain |
| forvex-train | Persona/competing-offer `source` examples mentioning “We Buy Ugly Houses” | Competitor offer roleplay |
| any | `/Users/homevestors/…` local paths in rumination/guides | Machine username; P3 — ignore or scrub opportunistically |
| any | `node_modules` / vendor | Ignore |

---

## Recommendations by action class

### 1. Theme rename (P0) — REpost, redeal-mobile, REbuild3

- New id: `slate-gold` (or `graphite-gold`).
- New display name: “Slate & Gold” (not “HomeVestors Brand”).
- Update CSS selectors, ThemeSelector copy, TypeScript unions, and any persisted `theme` preference migration (map old → new once).
- Effort: medium (UI + preference migration).

### 2. Prompt / persona rebrand (P0) — readvise + forvex-train

- Replace “HomeVestors coach/mentor/franchisee/playbook” with forVEX / “franchise operator” / “investor-buyer” language.
- Touch: `advisors/*.md`, `lib/prompts/*.md`, `lib/advisor-prompts.ts`, voice builders, train `lib/prompts/*`.
- Rebuild prompt artifacts if readvise `build:prompts` compiles from markdown.
- Effort: large (behavior change; smoke-test advisors + train scoring).

### 3. Marketplace & workflow strings (P0/P1) — readvise

- Neutralize default deal terms, intake placeholder, public marketplace HTML audience line.
- Rename workflow definition display names.
- Effort: small–medium + tests.

### 4. Emails & fixtures (P1)

- recontrol scripts → `process.env.IMPERSONATE_EMAIL` or example.com.
- Remove/redact `temp_log.md`, planning JSON emails, comment examples.
- Effort: small.

### 5. Docs / README soft scrub (P2)

- Prioritize README affiliation lines and Wave 1 docs that were historically public.
- Color-scheme recommendation docs in REpost can be rewritten or marked historical.
- Effort: medium (many files, low risk).

### 6. Git history / authors (P2)

- Keep private; document that author identity `Homevestors` appears in recontrol history.
- Optional follow-up: `git filter-repo` mailmap/author rewrite — only with explicit approval.
- Effort: high risk if done; defer.

### 7. Follow-up guardrail (after remediations)

- Add a CI `rg` ban-list for affiliation patterns (`HomeVestors Brand`, `@homevestors.com`, `data-theme="homevestors"`, “Private HomeVestors”) while allowing competitor-alias files via allowlist.
- Effort: small once inventory accepted.

---

## Suggested remediation waves

| Wave | Focus | Repos | Est. effort |
|---|---|---|---|
| **R1** | Theme rename + selector/CSS/prefs | REpost, redeal-mobile, REbuild3 | 1–2 days |
| **R2** | Advisor + train prompt rebrand | readvise, forvex-train | 2–4 days + QA |
| **R3** | Marketplace defaults, workflows, public HTML, READMEs | readvise, crg-dma | 0.5–1 day |
| **R4** | Scripts/emails/fixtures + “our company” comment cleanup | recontrol, readvise, redeal-mobile | 0.5 day |
| **R5** | Doc soft scrub (Wave 1 + color docs + core research) | recontrol, reecosystem-core, REpost | 1 day |
| **R6** | Optional history purge / author rewrite | recontrol (if mandated) | Ops project |

---

## Success criteria for a future remediation pass

- No user-visible theme or UI string named HomeVestors.
- No shipped advisor/train system prompt claiming HV affiliation.
- No hardcoded `@homevestors.com` in active scripts/fixtures.
- Competitor-intel aliases and competing-offer examples may remain.
- Remotes stay private; CI ban-list optional.

---

## Method notes

- Patterns: `Homevestors?`, `HomeVestors`, `We Buy Ugly`, `uglyhouses`, `homevestors.com`, theme id `homevestors`.
- Excluded: `node_modules` / vendor noise where possible.
- Wave 1 included `gh repo view` + `git log -S` history sampling.
- This audit is technical/product hygiene, not a legal opinion.
