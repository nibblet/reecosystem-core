# forVEX Ecosystem Map

**Status:** Orchestration routing reference
**Owner:** reecosystem-core
**Companion:** [`AGENT_CONVENTIONS.md`](./AGENT_CONVENTIONS.md) (the shared standard) ·
[`SKILL_SYSTEM_CONTRACT.md`](./SKILL_SYSTEM_CONTRACT.md) (the wire/identity contract)

> Use this to **route any cross-repo task**: find the repo that *owns* the surface
> being changed, send the change there first (contract-first, see
> `AGENT_CONVENTIONS.md` §7), then have dependent repos mirror.

---

## 1. Who owns what

| Repo | Role in forVEX | Owns (authoritative) | Consumes / mirrors |
|------|----------------|----------------------|--------------------|
| **reecosystem-core** | Canonical contracts + orchestrator home base | The horizontal contract (`SKILL_SYSTEM_CONTRACT.md`): identity model, source-of-truth registry, canonical enums, write discipline, routing. Multi-app architecture intent (`ARCHITECTURE.MD`). This standard (`AGENT_CONVENTIONS.md`). | Nothing — it is the top of the mirror chain. |
| **recontrol** | Admin **control plane** | **The MCP server + tool registry** (`lib/mcp/tools/**`, `outputSchemas.ts`, transport `app/api/[transport]/route.ts`) that LLM clients call · the **REST twin** `app/api/operate/**` that human underwriting clients call (same loaders and `runUnderwrite`) · OAuth bridge · **authoritative** comp + underwriting engines · authoritative runtime *values* (tier rates, thresholds, fee schedules). | Canonical enum/identity *shapes* from reecosystem-core; vendors `@nibblet/rebuild-engine`. |
| **readvise** | Downstream **operating surface** · **reference implementation** | The `readvise.*` schema + its API (pipeline, notes, pulse, tasks, advisor workspace). Pure underwriting **parsers** in `lib/operate/utils/` (shared with mobile). | MCP tools (from recontrol); underwriting analysis (not the authority); mirrors `@nibblet/rebuild-engine` in `rebuild_packages/`; mirrors the rebuild `ai-tools` domains. |
| **readvise-ios** | Operating companion (iOS) | Its UI and local display rules only. | Readvise API (Supabase session). Reads pipeline, notes, tasks, Sense, Reflect, and the saved underwriting record. Writes only what Readvise owns: stage, task status, pulse, investor preferences. Stage and exit-reason enums mirror `SKILL_SYSTEM_CONTRACT` §3.4. Does not underwrite and does not speak MCP. |
| **forvex-underwrite** | Underwriting desk (iOS / Android) | Its UI, navigation, and theme tokens only. | recontrol `/api/operate/*` (not MCP, not through Readvise). Vendors `@nibblet/underwrite-engine` for slider display: the server resolves, the client recomputes from `effective_input`, the server persists. |
| **rebuild** | Construction / valuation packages | **The pure, portable estimate engine** `@nibblet/rebuild-engine` (`packages/rebuild-engine/`), wire shape versioned by `CONTRACT_VERSION`. The `forvex-build` app (`rebuild3/`) + root `supabase/migrations/`. | Canonical enums/identity from core. Its engine is vendored by recontrol + mirrored by readvise (downstream of its own contract). |
| **redeal-mobile** | Vertical mobile + Claude skills | Vertical skill workflows (`skills/ARCHITECTURE.md`), per-tool wire schemas (`docs/comps_v2_contract.md`), MCP build sequence. | **MCP tool consumer** (from recontrol). No build-agent team yet. |

**Mirror chain (top → down):** reecosystem-core → recontrol (MCP + values) /
rebuild (engine) → readvise, readvise-ios, forvex-underwrite, redeal-mobile (consumers).

**Doors.** One law, three entry points. Do not invent a fourth.

| Who | Door | Never |
|-----|------|-------|
| Skills and bots (the hands) | recontrol **MCP** | A phone, or a second copy of the math |
| Human underwriting desk (`forvex-underwrite`) | recontrol **`/api/operate`** — same engines and IDs as the MCP tools | MCP, the OAuth bridge, or a hop through Readvise |
| Operating surface (Readvise web, `readvise-ios`) | **Readvise API** | recontrol engines, MCP, or a locally derived ARV / MAO |

Eyes / hands / brain still names the agent stack: bots act, MCP decides numbers and IDs, Readvise shows the record. The phones are operator surfaces on the doors above, not more bots and not a second brain.

---

## 2. Agent surface per repo — AUTHORITATIVE ROUTING ROSTER

> This table is the **authoritative roster** for cross-repo dispatch
> (`AGENT_CONVENTIONS.md` §10). Role names are repo-local and duplicated, so the
> orchestrator routes by **repo name + absolute agent path**, never by bare role
> name. Keep this in sync whenever a repo adds/renames/removes an agent.

Tools/model are standardized (`AGENT_CONVENTIONS.md` §2–§3): read-only roles =
`Glob, Grep, Read[, WebFetch]`; writers = `+ Edit, Write, Bash`; all `model: opus`.

| Repo | Agents dir (absolute) | architect | feature-builder | reviewer | ui-engineer | migrator | mcp-engineer | Specialist notes |
|------|----------------------|:--:|:--:|:--:|:--:|:--:|:--:|------|
| **readvise** | `/Volumes/Lexar/readvise/.claude/agents/` | ✅ | ✅ | ✅ | ✅ | ✅ | — | Reference 5-agent set. |
| **recontrol** | `/Volumes/Lexar/recontrol/.claude/agents/` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Adds **mcp-engineer** (owns the tool contract). |
| **rebuild** | `/Volumes/Lexar/REbuild3/.claude/agents/` | ✅ | ▲ `domain-engineer` | ✅ | ✅ | ✅ | — | Builder is the sanctioned alias **domain-engineer** (pure engine focus). |
| **reecosystem-core** | `/Volumes/Lexar/reecosystem-core/.claude/` (no `agents/`) | — | — | — | — | — | — | Contracts/orchestration only; no build-agent team today (see §4). |
| **forvex-underwrite** | `/Volumes/Lexar/forvex-underwrite/.claude/agents/` | — | — | ✅ | — | — | — | Desk app. **app-builder** (UI), **contract-keeper** (API / engine seam). No MCP. |
| **readvise-ios** | — | — | — | — | — | — | — | No team. Operating companion; UI and display rules only (see §4). |
| **redeal-mobile** | — | — | — | — | — | — | — | No team yet; MCP consumer (see §4). |

Legend: ✅ present · ▲ present under a sanctioned alias · — not present.

**Dispatch example (repo-qualified):** to review a recontrol change, target
`recontrol` + `/Volumes/Lexar/recontrol/.claude/agents/reviewer.md`, and pass
repo-absolute paths for the files under review. Bare `reviewer` is ambiguous across
every team that has one and must not be used for cross-repo dispatch.

**Stability heartbeat:** present in readvise, recontrol, rebuild — each tuned to
that repo's env-independent suites (`AGENT_CONVENTIONS.md` §8).

**Upstream reachability (Tier-2 dependency):** the GitHub remote now exists —
`github.com/nibblet/reecosystem-core`. The mirror Tier-2 CI jobs
(`AGENT_CONVENTIONS.md` §7.1) fetch `raw.githubusercontent.com/nibblet/
reecosystem-core/main/contracts/contract-version.json`. They go **green only once
`contracts/contract-version.json` is on `main`** of that remote — the final unblock
step. Tier-1 (vendored) is unaffected and green today.

---

## 3. Routing quick-reference (where does this change start?)

| If the task touches… | Start in… | Owning agent |
|----------------------|-----------|--------------|
| An MCP tool's name / input / output | **recontrol** | mcp-engineer |
| A shared id / enum / source-of-truth number | **reecosystem-core** (contract) → then owner | architect → reviewer |
| The estimate/valuation engine wire shape | **rebuild** (`CONTRACT_VERSION` bump) | domain-engineer |
| Pipeline / notes / pulse / advisor UX | **readvise** | feature-builder / ui-engineer |
| Pipeline / Sense / Reflect **phone** UI | **readvise-ios** for display. The API and schema still start in **readvise**. The phone must not re-derive numbers. | (no team — hand to its session); readvise feature-builder if the API moves |
| Underwriting desk UI, or anything `/api/operate` returns to it | **recontrol** first (engine or route), then mirror types in **forvex-underwrite**. The desk does not start a shared change. | mcp-engineer, then contract-keeper |
| A schema migration | the repo owning that schema | migrator |
| A vertical mobile skill workflow | **redeal-mobile** | (no team — hand to its session) |

---

## 4. Gaps & follow-ups (orchestrator backlog)

- **readvise-ios** has no build-agent team. It is an operating companion, not an
  engine. A team, if added, is UI-only and must not grow a second underwriting path.
- **redeal-mobile** has no build-agent team yet. As an MCP *consumer* it warrants
  at least `architect` + `feature-builder` + `reviewer` (reviewer enforcing the
  cross-repo protocol), plus `ui-engineer` for the mobile surface. Propose when ready.
- **reecosystem-core** itself could host a lightweight `architect` + `reviewer`
  pair for contract edits, since contract changes are the highest-leverage cross-repo
  events. Optional.
- **rebuild builder-name watch:** `domain-engineer` is a sanctioned alias, but it
  must also cover non-pure app glue in `rebuild3/` so there's no coverage gap. If
  app-side feature work grows, consider adding a plain `feature-builder` alongside it.
- **`ai-tools` mirror:** the construction/valuation advisory domains physically live
  in `readvise:rebuild_packages/ai-tools/` with no canonical counterpart dir in
  rebuild today. Track this as drift to reconcile (decide the canonical home).
