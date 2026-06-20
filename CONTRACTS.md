# Contracts & Architecture — reecosystem-core

> Pointer file. Authoritative definitions live in the linked docs, not here.
> If this file and a linked doc disagree, the linked doc wins.

## This repo owns

- Multi-app architecture intent (`ARCHITECTURE.MD`) — bounded write ownership, canonical spines, RLS expectations
- Shared schema/types/enums **when extracted here** (target state; not fully populated yet)
- **The canonical horizontal contract** — `docs/SKILL_SYSTEM_CONTRACT.md`
- Phase 1 discovery inventory — `docs/SKILL_SYSTEM_CONTRACT_discovery.md`
- **The build-agent standard** — `docs/AGENT_CONVENTIONS.md` (how every repo sets up `.claude/agents`, CLAUDE.md, hygiene, heartbeat, cross-repo protocol)
- **Ecosystem routing map** — `docs/ECOSYSTEM_MAP.md` (who-owns-what + the agent surface per repo)

## Canonical cross-repo docs (read before changing shared behavior)

Reference each as `repo:path` and full GitHub URL.

| Doc | Location | GitHub |
|-----|----------|--------|
| Horizontal skill/MCP contract | `reecosystem-core:docs/SKILL_SYSTEM_CONTRACT.md` | https://github.com/nibblet/reecosystem-core/blob/main/docs/SKILL_SYSTEM_CONTRACT.md *(pending — no GitHub remote yet)* |
| Vertical architecture | `redeal-mobile:skills/ARCHITECTURE.md` | https://github.com/nibblet/redeal-mobile/blob/main/skills/ARCHITECTURE.md |
| Multi-repo ownership brief | `redeal-mobile:docs/FORVEX_MULTI_REPO_REFACTOR_BRIEF.md` | https://github.com/nibblet/redeal-mobile/blob/main/docs/FORVEX_MULTI_REPO_REFACTOR_BRIEF.md |
| Comps tool contract | `redeal-mobile:docs/comps_v2_contract.md` | https://github.com/nibblet/redeal-mobile/blob/main/docs/comps_v2_contract.md |
| MCP build sequence/decisions | `redeal-mobile:skills/MCP_BUILD_SEQUENCE.md` | https://github.com/nibblet/redeal-mobile/blob/main/skills/MCP_BUILD_SEQUENCE.md |

## Before you change X, read Y

- **Add/modify an MCP tool** → `SKILL_SYSTEM_CONTRACT.md` §4 MCP topology + implement in **recontrol**
- **Touch a shared id / `deal_id`** → `SKILL_SYSTEM_CONTRACT.md` §1 Identity model
- **Produce/consume a derived number** → `SKILL_SYSTEM_CONTRACT.md` §2 Source-of-truth registry
- **Add a strategy/tier/enum** → `SKILL_SYSTEM_CONTRACT.md` §3 Canonical enums — define once in **recontrol**, mirror here only if shared package exists
- **Add a write path** → `SKILL_SYSTEM_CONTRACT.md` §6 Write discipline
- **Add or trigger a new skill** → `SKILL_SYSTEM_CONTRACT.md` §7 Skill routing & precedence

## Rule

Authoritative values live server-side in **recontrol**. This file and the contract docs carry **names and pointers**, never copied values.
