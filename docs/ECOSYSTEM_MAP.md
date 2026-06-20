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
| **recontrol** | Admin **control plane** | **The MCP server + tool registry** (`lib/mcp/tools/**`, `outputSchemas.ts`, transport `app/api/[transport]/route.ts`) that other repos call · OAuth bridge · **authoritative** comp + underwriting engines · authoritative runtime *values* (tier rates, thresholds, fee schedules). | Canonical enum/identity *shapes* from reecosystem-core; vendors `@nibblet/rebuild-engine`. |
| **readvise** | Downstream **operating surface** · **reference implementation** | The `readvise.*` schema + its API (pipeline, notes, pulse, tasks, advisor workspace). Pure underwriting **parsers** in `lib/operate/utils/` (shared with mobile). | MCP tools (from recontrol); underwriting analysis (not the authority); mirrors `@nibblet/rebuild-engine` in `rebuild_packages/`; mirrors the rebuild `ai-tools` domains. |
| **rebuild** | Construction / valuation packages | **The pure, portable estimate engine** `@nibblet/rebuild-engine` (`packages/rebuild-engine/`), wire shape versioned by `CONTRACT_VERSION`. The `forvex-build` app (`rebuild3/`) + root `supabase/migrations/`. | Canonical enums/identity from core. Its engine is vendored by recontrol + mirrored by readvise (downstream of its own contract). |
| **redeal-mobile** | Vertical mobile + Claude skills | Vertical skill workflows (`skills/ARCHITECTURE.md`), per-tool wire schemas (`docs/comps_v2_contract.md`), MCP build sequence. | **MCP tool consumer** (from recontrol). No build-agent team yet. |

**Mirror chain (top → down):** reecosystem-core → recontrol (MCP + values) /
rebuild (engine) → readvise + redeal-mobile (consumers).

---

## 2. Agent surface per repo

Tools/model are standardized (`AGENT_CONVENTIONS.md` §2–§3): read-only roles =
`Glob, Grep, Read[, WebFetch]`; writers = `+ Edit, Write, Bash`; all `model: opus`.

| Repo | architect | feature-builder | reviewer | ui-engineer | migrator | mcp-engineer | Specialist notes |
|------|:--:|:--:|:--:|:--:|:--:|:--:|------|
| **readvise** | ✅ | ✅ | ✅ | ✅ | ✅ | — | Reference 5-agent set. |
| **recontrol** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Adds **mcp-engineer** (owns the tool contract). |
| **rebuild** | ✅ | ▲ `domain-engineer` | ✅ | ✅ | ✅ | — | Builder is the sanctioned alias **domain-engineer** (pure engine focus). |
| **reecosystem-core** | — | — | — | — | — | — | Contracts/orchestration only; no build-agent team today (see §4). |
| **redeal-mobile** | — | — | — | — | — | — | No team yet; MCP consumer (see §4). |

Legend: ✅ present · ▲ present under a sanctioned alias · — not present.

**Stability heartbeat:** present in readvise, recontrol, rebuild — each tuned to
that repo's env-independent suites (`AGENT_CONVENTIONS.md` §8).

---

## 3. Routing quick-reference (where does this change start?)

| If the task touches… | Start in… | Owning agent |
|----------------------|-----------|--------------|
| An MCP tool's name / input / output | **recontrol** | mcp-engineer |
| A shared id / enum / source-of-truth number | **reecosystem-core** (contract) → then owner | architect → reviewer |
| The estimate/valuation engine wire shape | **rebuild** (`CONTRACT_VERSION` bump) | domain-engineer |
| Pipeline / notes / pulse / advisor UX | **readvise** | feature-builder / ui-engineer |
| A schema migration | the repo owning that schema | migrator |
| A vertical mobile skill workflow | **redeal-mobile** | (no team — hand to its session) |

---

## 4. Gaps & follow-ups (orchestrator backlog)

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
