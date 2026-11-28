# forVEX account deletion standard

**Status:** adopted 2026-11-28 (Paul). **Applies to:** every forVEX app that signs people in.
**Implementation:** `recontrol` migration `20261128150000_core_account_deletion.sql`
(contract in `recontrol:CONTRACTS.md`, "Account deletion").

## Why this exists

forVEX apps are sold on their own, but they share one sign-in (`auth.users` / `core.users`)
and workspaces (`core.workspaces`). An app that deletes "its" account by deleting the sign-in
or a workspace deletes another app's data with it. So the rules live in `core`, and an app
only calls them.

## What a person is offered

Every app that lets people create an account offers deletion inside the app, from Settings
(App Store guideline 5.1.1(v)). The person gets two choices:

1. **Delete my `<app>` account.** The app's data is removed. The forVEX sign-in is deleted
   too when nothing else uses it. Otherwise it stays, and the screen says which app keeps it.
2. **Delete my whole forVEX account.** Every app's account is closed and the sign-in is
   deleted. This choice is **required** whenever the first one would keep the sign-in. It
   is not shown when the first one already deletes the sign-in.

Before confirming, the person sees what will happen in plain words, from the server's own
plan and not from wording fixed in the app: what is deleted, whether the sign-in stays and
why, any workspace they will be removed from, and any subscription that deleting does not
cancel. If the delete cannot run, the screen gives the reason instead of a Delete button.

## Rules the database enforces

These are in `core.rpc_delete_account` and are not an app's to change.

- **One transaction.** Everything is deleted, or nothing is.
- **The workspace follows the sign-in.** A workspace is deleted only when the sign-in is,
  only when the person is its sole member, and only when it is a personal workspace.
  Closing one app never deletes a workspace.
- **Team workspaces are never deleted by self-serve.** A team's owner is told to hand it
  over first.
- **An app's rows are purged only in workspaces the person is alone in.** In a shared
  workspace the person only loses membership, and only when the sign-in goes. Rows that
  belong to the person and not to the workspace (a practice history, personal preferences)
  go wherever they are.
- **When unsure, the sign-in stays.** An app counts as "in use" if it has an open
  `core.app_accounts` row, an enabled entitlement, or any data found by `core.apps`.
- **Refused with a clear message:** platform admins; the sole owner of a workspace other
  people use; team owners; anyone who uses an app that has not shipped its purge function
  (the whole-account choice only).
- **A shared workspace never ends up without an owner.** When its owner's sign-in goes,
  ownership passes to the longest-standing other owner.
- **Files are removed after the commit.** A purge queues them in `core.file_purge_queue`;
  REcontrol's `account_file_purge` job removes them. Nothing leaves storage before the
  transaction commits.
- **Every deletion is logged** in `core.account_deletions`, without the person's email.
- **Closed entitlements stay as rows** (`enabled = false`, `features.closed_at`,
  `features.closed_reason = 'account_deleted'`). Coming back reopens the same row, with no
  second free trial.

## What each app ships

1. **A row in `core.apps`**: its key, name, schema, buckets, and any user-id columns that
   have no foreign key (`user_columns`).
2. **Two functions in its own schema**, registered on that row and callable only by core:
   - `<schema>.account_plan(p_user_id uuid, p_workspace_ids uuid[]) returns jsonb`: counts
     for the preview. Read-only.
   - `<schema>.account_purge(p_user_id uuid, p_workspace_ids uuid[]) returns jsonb`: deletes
     the app's rows. `p_workspace_ids` is the workspaces the person is alone in, the only
     ones whose shared rows it may touch. It never deletes a sign-in, a workspace or a file;
     it queues files with `core.queue_workspace_files` or `core.queue_files`.
3. **A call to `core.rpc_open_app_account(app)`** after sign-in or sign-up.
4. **The screen**: preview from `core.rpc_account_deletion_plan(app, scope)`, delete with
   `core.rpc_delete_account(app, scope, 'DELETE')`, both as the signed-in person. No
   service-role key. Sign out afterwards, on this device at least.
5. **Sign in with Apple**: when the sign-in is deleted, revoke the person's Apple tokens
   (the app sends a fresh authorization code; the server exchanges and revokes it).
6. **Subscriptions**: deleting does not cancel an App Store subscription. Say so in the
   preview, and keep the subscription record so a late renewal can be matched.
7. **The privacy policy and support page** describe both choices and what stays.

## Schema rules for every repo

- A new foreign key to `auth.users`, `core.users` or `core.workspaces` declares
  `ON DELETE CASCADE` or `ON DELETE SET NULL`. Never the default, never `RESTRICT`.
- A user-id column without a foreign key is listed in the app's `core.apps.user_columns`.
- No app deletes from `auth.users`, `core.workspaces` or `storage.objects`.
- Functions callable by signed-in users check the caller in the body; internal ones are
  revoked from `anon` and `authenticated` (REadvise's `anon-rpc-surface` test checks this).

## REcontrol

Admins see which apps each person uses, can delete on someone's behalf (same rules, with a
reason, audited), and have an Account deletions page with the log and the file backlog.

## Adoption

| App | State |
|---|---|
| REbuild (web + iPhone) | Adopted, `rebuild3` 0.24.0 / iOS 0.39.0 |
| Train (web + iPhone) | Adopted |
| REadvise | Not yet. Needs a hand-over of the person's rows to the workspace owner before its purge function; until then its users cannot use the whole-account choice and are pointed to admin@forvex.app |
| REdeal | Not yet (its repo points at an older database) |
| Scan, Underwrite | Sign in only; no account is created there, so no delete screen is required |

Contact for manual requests: admin@forvex.app.
