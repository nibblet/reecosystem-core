# forVEX Build-Agent Conventions

**Status:** Canonical standard for Claude Code build-agent teams across the forVEX
ecosystem
**Version:** 1.0.0
**Owner:** reecosystem-core (orchestrator home base)
**Reference implementation:** `readvise` (when in doubt, match readvise)

> This is the single source of truth for how every repo sets up its **build
> agents** (`.claude/agents/`), its **CLAUDE.md**, its **hygiene**, its
> **stability heartbeat**, and how it participates in **cross-repo changes**.
> Each repo's CLAUDE.md should *point here* rather than re-stating these rules.
> If a repo needs to deviate, it documents the deviation in its own CLAUDE.md and
> flags it to the orchestrator — it does not silently fork the standard.

This document governs the *build* layer (the agents that write code). It does
**not** govern runtime product behavior or wire contracts — those live in
`CONTRACTS.md` → `docs/SKILL_SYSTEM_CONTRACT.md`.

---

## 1. The two agent layers (never conflate them)

Every repo has two distinct "agent" concepts. CLAUDE.md must name both:

1. **Runtime product AI** — the product's own AI (MCP tools, advisor prompts,
   intake/inference, LLM orchestration). Editing this changes product behavior and
   often a wire contract.
2. **Build agents** — the Claude Code subagents in `.claude/agents/` that write and
   maintain the codebase. This is the layer these conventions govern.

---

## 2. Core role taxonomy (every repo shares these three)

These three exist in **every** repo, with identical tools and `model: opus`:

| Role | Purpose | Tools | Writes? |
|------|---------|-------|---------|
| **architect** | Read-only planner. Plans non-trivial / cross-cutting changes BEFORE code. Flags contract / ownership / purity / sync concerns. Recommends one approach. | `Glob, Grep, Read, WebFetch` | No |
| **feature-builder** | Primary implementer of server/logic feature slices. Keeps API routes thin, logic in `lib/`, ships a test per change. | `Glob, Grep, Read, Edit, Write, Bash` | Yes |
| **reviewer** | Read-only. Reviews a diff/branch for correctness bugs **and** forVEX contract/ownership violations before commit/PR. | `Glob, Grep, Read, Bash` | No |

### 2.1 Sanctioned alias of `feature-builder`

A repo whose primary build work **is** a pure, portable domain package (not
generic app glue) may rename `feature-builder` to a **domain-named equivalent**.
One sanctioned alias exists today:

| Canonical | Sanctioned alias | Used by | When it applies |
|-----------|------------------|---------|-----------------|
| `feature-builder` | **`domain-engineer`** | rebuild | The repo's core deliverable is pure domain/engine logic (e.g. the estimate engine) where purity + a versioned wire contract are the point. |

> The alias is **legal, not preferred**. Default to `feature-builder`. If you adopt
> `domain-engineer`, the role still owns the repo's non-pure app glue too (so there
> is no coverage gap), and its body must carry the purity + contract-version rules.
> Any *other* off-standard builder name is non-conforming and should be renamed to
> one of these two.

---

## 3. Sanctioned specialists (add only when the surface exists)

Beyond the core three, add a specialist **only if the repo actually has that
surface**. Do not create an agent for a surface that doesn't exist.

| Specialist | Add when the repo… | Tools | Notes |
|-----------|--------------------|-------|-------|
| **ui-engineer** | …has an app UI (components / pages / App-Router screens) | `Glob, Grep, Read, Edit, Write, Bash` | Presentation only; wires to existing API/logic; never touches pure shared packages or redefines canonical types. |
| **migrator** | …owns or evolves a database (migrations / RLS / RPC) | `Glob, Grep, Read, Edit, Write, Bash` | Additive migrations; RLS stated explicitly; **never** destructive/remote-applied without explicit human sign-off. The DB is shared and live. |
| **mcp-engineer** | …owns MCP tools (today: **recontrol only**) | `Glob, Grep, Read, Edit, Write, Bash` | Guards the tool wire contract (`lib/mcp/tools/**` + `outputSchemas`) that downstream repos consume. Never breaks a tool signature without flagging the downstream blast radius; prefers additive evolution. |

**Conventions are not mandates to fill every slot.** A pure-package repo with no UI
omits `ui-engineer`; a repo with no DB omits `migrator`. Only recontrol has
`mcp-engineer`.

---

## 4. Agent file format

Every `.claude/agents/<name>.md` uses YAML frontmatter + a tight role body:

```markdown
---
name: <role>                 # matches the canonical taxonomy (or sanctioned alias)
description: <when to use this agent — concrete triggers, what it returns>
tools: <comma-separated>      # read-only roles get NO Edit/Write/Bash-mutation
model: opus
---

<Role body: 1 screen. State the repo's role, the SACRED surface it must protect,
the cross-repo law (point at CONTRACTS.md), the concrete paths, and the
workflow/output. Read-only agents say "I do not edit." End writers with a
contract/impact note instruction.>
```

Rules:
- **Read-only roles** (`architect`, `reviewer`) get only read/search tools — never
  `Edit`/`Write`.
- **`model: opus`** for all build agents.
- The body **names the repo's sacred surface** and the "flag-don't-diverge" law
  (see §7). Generic bodies are a smell — cite real paths.

---

## 5. CLAUDE.md section template

Keep it short and true; if it drifts from reality, fix the file. Required sections:

1. **What this is** — one paragraph: the app + its **role in forVEX** (and what it
   is *not* — e.g. "not a monorepo"; "consumes underwriting, not the authority").
2. **Cross-repo law** — point at the repo's `CONTRACTS.md` and the canonical
   `reecosystem-core:docs/SKILL_SYSTEM_CONTRACT.md`. State the non-negotiables:
   canonical enums / identity / source-of-truth live in reecosystem-core (MCP tools
   in recontrol); local copies only mirror, never redefine. Name the repo's own
   **sacred surface**.
3. **The two agent layers** — runtime product AI vs build agents (§1).
4. **Commands** — the *real* build / run / test commands (verified, not aspirational).
5. **Domain → path map** — a table of where things live.
6. **House rules** — tests alongside changes; run lint before done; prefer fewer
   living docs over status markdown; stay on the assigned branch.
7. **Pointer** — "These build-agent conventions are standardized in
   `reecosystem-core:docs/AGENT_CONVENTIONS.md`; this file only records what is
   specific to <repo>."

---

## 6. Hygiene & doc discipline

### 6.1 Git tracking
- **Never track**: `node_modules/`, Claude worktrees (`/.claude/worktrees/`,
  `/.worktrees/`), build output (`.next/`, `out/`, `build/`, `dist/` — see
  exception below), `*.tsbuildinfo`, local env files, raw data dumps containing PII.
- **Always track**: `.claude/agents/` and `.claude/commands/`.
- **Ignore local Claude state** (`.claude/settings.local.json`, `launch.json`,
  worktrees) while whitelisting the shared config. Canonical `.gitignore` block:
  ```gitignore
  /.claude/*
  !/.claude/agents/
  !/.claude/commands/
  /.claude/worktrees/
  /.worktrees/
  ```
- **`dist/` exception:** a *pure published/vendored package* (e.g.
  `rebuild`'s `@nibblet/rebuild-engine`) may commit its built `dist/` **on purpose**
  because consumers vendor the artifact (`recontrol/vendor/rebuild-engine`).
  Untracking it would break the vendoring contract. When a repo commits `dist/`
  deliberately, it says so — don't "clean it up" without checking consumers.
- Untrack accidental commits with `git rm -r --cached <path>` (keeps the working
  copy); add an ignore rule so it can't return.

### 6.2 Documentation audit (LEGACY / LIVING / AMBIGUOUS)
Historical markdown confuses agents. Periodically bucket every tracked doc:
- **LEGACY** — status/completion markers (`✅`, "DONE", "ARCHIVED", "applied to
  prod"), one-off debug/fix/findings/verification/audit runbooks, deprecation
  reports, versioned backups. → **delete candidates.**
- **LIVING** — architecture, contracts, active guides, nav indexes. → **keep.**
- **AMBIGUOUS** — plans/PRDs/design docs that may still be active. → **human call.**

Discipline: **present the bucketed kill-list and get human approval before
deleting.** Git history is the safety net. After deleting, **repair dangling links**
in surviving nav docs (scan survivors for references to deleted basenames). Prefer
**fewer, living** docs.

---

## 7. Cross-repo change protocol (contract-first)

This is the rule every **reviewer** enforces and every **architect** plans around.

**A shared id / enum / derived number / MCP tool signature changes at its source
of truth FIRST, then dependent repos mirror. Never a local redefinition.**

| What changes | Where it changes first | Then |
|--------------|------------------------|------|
| Shared id / `deal_id` / identity | `reecosystem-core` → `SKILL_SYSTEM_CONTRACT.md` §1 | repos mirror the resolved id; never mint locally |
| Canonical enum / strategy / tier | defined once (recontrol server-side; named in core §3) | repos import/mirror; never fork the enum |
| Derived / source-of-truth number | its authoritative owner (`SKILL_SYSTEM_CONTRACT.md` §2) | consumers read it; never recompute divergently |
| **MCP tool name / input / output** | **recontrol** (`lib/mcp/tools/**` + `outputSchemas`) | `readvise`, `redeal-mobile` consumers mirror; **flag the blast radius** |
| Pure engine wire shape (`EngineInput`/`IntakeResult`) | `rebuild` (`@nibblet/rebuild-engine`), bump `CONTRACT_VERSION` | `recontrol` vendor + `readvise` mirror re-pin |

Operating rules:
- **Flag, don't diverge.** If a change would require diverging from a contract,
  stop and route it to the owner repo first (see the orchestrator /
  `ECOSYSTEM_MAP.md`).
- **Additive over breaking.** Add optional fields / new tools / widened unions
  before renaming or removing.
- The full horizontal protocol (identity, source-of-truth registry, enums, write
  discipline, routing) is authoritative in
  `reecosystem-core:docs/SKILL_SYSTEM_CONTRACT.md` — this section is its build-agent
  summary, not a replacement.

### 7.1 Every mirror ships a two-tier drift guard (REQUIRED)

A comment that says "mirror — do not diverge" is not enforcement; a hand-copied
literal silently drifts the moment canonical bumps. So **every local mirror of a
canonical value** (the version stamp, a mirrored enum, a source-of-truth number)
**must ship two tests**, matching our local-vs-CI split:

- **Tier 1 — local, offline, deterministic.** A unit test asserting the mirror
  constant equals the canonical value the repo *consumes*. Source of canonical:
  - if the repo consumes `reecosystem-core` as a **package/submodule** → import the
    canonical artifact (e.g. `contracts/contract-version.json`) directly from there;
  - else → **vendor a pinned copy** of the canonical artifact into the repo and
    assert `mirror === vendored`. State which mechanism the repo uses.
  This test is pure (no network) and **must live in the env-independent suite** so
  the `stability-heartbeat` (§8) catches drift locally.
- **Tier 2 — CI, networked.** A GitHub Actions job that checks the repo's
  consumed/vendored copy against **live `reecosystem-core` main** (checkout, or
  fetch raw `contracts/contract-version.json`). It **fails when upstream bumped and
  this repo has not re-synced**. This is the durable guard; it belongs in CI where
  network + secrets live, never in the local heartbeat.

This is the standard for **all** future mirrored contracts, not just the version
stamp. A mirror without both tiers is non-conforming. (Tier 2 requires
`reecosystem-core` to be reachable — see the remote note in `ECOSYSTEM_MAP.md`.)

---

## 8. Loop / CI pattern (stability-heartbeat)

Two tiers of guard, deliberately separated:

- **`stability-heartbeat`** (`.claude/commands/stability-heartbeat.md`) — a
  **token-modest, env-independent** tripwire for in-session loops. It runs only the
  suites that can genuinely go **green locally without secrets** (pure unit suites:
  MCP output-contract + comp engine in recontrol; the pure engine suite in rebuild;
  the env-independent jest suites in readvise). On green: report one line and stop —
  no investigation, no commit. On red: report the failing suite + first assertion
  and **hand off to the owning agent** (do not fix in the heartbeat).
- **CI (GitHub Actions / Vercel)** — the **durable** full guard: complete
  `lint` + the env-dependent / DB / live suites, which are red-by-construction in a
  credential-less container and therefore belong where secrets exist. The heartbeat
  never tries to replace CI.

Each repo tunes the heartbeat's command to *its* pure suites; the doctrine is shared.

---

## 9. Conformance checklist (per repo)

- [ ] CLAUDE.md follows the §5 template and **points at this doc** (§5.7).
- [ ] `.claude/agents/` has `architect` + `feature-builder`(or sanctioned
      `domain-engineer`) + `reviewer`, plus only the specialists whose surface exists.
- [ ] Agent names/tools/model match §2–§4 (read-only roles have no Edit/Write).
- [ ] `.gitignore` matches the §6.1 block; no tracked node_modules/worktrees/build
      output (except a deliberate vendored `dist/`).
- [ ] A `stability-heartbeat` command tuned to the repo's env-independent suites (§8).
- [ ] reviewer body enforces the §7 cross-repo change protocol.
- [ ] Every local contract mirror ships a Tier-1 equality test (env-independent) +
      a Tier-2 upstream-sync CI job (§7.1).

---

## 10. Cross-repo agent routing (repo-qualified dispatch)

Role names are **repo-local and intentionally duplicated** — every repo has its own
`architect` / `reviewer` / etc. That keeps in-repo ergonomics simple (a developer in
recontrol just says "reviewer"). But it means a **role name alone is ambiguous to the
orchestrator**: "run the reviewer" could hit any of three repos.

**Convention (chosen — low-churn): every cross-repo dispatch is repo-qualified.**
The orchestrator never dispatches by bare role name. A dispatch must carry:
1. the **target repo name**, and
2. the agent's **absolute path** (e.g. `/Volumes/Lexar/recontrol/.claude/agents/reviewer.md`),
   plus repo-absolute paths for any files the agent will touch.

The **authoritative roster** of which roles exist in which repo (with absolute paths)
lives in `ECOSYSTEM_MAP.md` §2. The orchestrator routes **from that map**, not from
memory or guesswork. When a repo adds/renames/removes an agent, it updates the
ECOSYSTEM_MAP roster in the same change.

**Rationale for low-churn over hard namespacing.** The alternative — renaming every
agent to `repo:role` (e.g. `recontrol:reviewer`) across all repos — was rejected: it
churns every repo's `.claude/agents/` filenames and frontmatter, breaks the clean
in-repo experience, and fights Claude Code's local agent-name model, all to solve an
ambiguity that only exists at the orchestrator layer. Solve it where it occurs: at
dispatch, with a real map. (If the ecosystem later adopts a shared agent registry
that supports namespacing natively, revisit.)
