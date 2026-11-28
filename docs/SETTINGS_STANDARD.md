# forVEX app Settings standard

One layout for Settings in every forVEX iPhone and iPad app (Train, Build, Underwrite, Scan),
so an owner who knows one knows them all. The apps are sold and used independently, so each
one must stand alone: nothing in Settings may assume, require or change another forVEX app.

Reference implementations: reScan for the layout (`reScan/Library/SettingsView.swift`,
`SettingsExtras.swift`); forVEX Train for choice cards; forVEX Build (REbuild) for AI consent,
the deletion preview, subscriptions and iPad. Adopted 2026-11-28 (Paul); the canonical copy is `reecosystem-core/docs/SETTINGS_STANDARD.md`.

Revision 4, 2026-11-28: the deletion rules move to `ACCOUNT_DELETION_STANDARD.md`; this file keeps only what Settings shows. Revision 3 (Paul's seven fixes: AI-first apps, optional Appearance, Apple sign-in only if offered, device wording, user-facing links only, expand-in-place, list or cards). Revision 2: adds iPad, the Plan group, appearance, workspaces, account-level AI
consent and the deletion preview; rewrites account deletion for independent apps.

## Where Settings lives

- **iPhone:** Settings is the last tab in the tab bar, with the screen header (title
  "Settings") over a list or a stack of cards on the Core canvas (see "Components by role").
- **iPad:** the same tab becomes the last sidebar item (`.tabViewStyle(.sidebarAdaptable)`),
  set apart from the work items. See "iPad".
- **Not a toolbar menu.** A menu can't hold the hero, footers, Your data or About. An app may
  keep a small account button in its toolbars, but it opens the Settings tab; it is not a
  second home for settings.
- If the tab bar is full, merge a work tab before dropping Settings (Build moved Contractors
  into Library to make room).

## The order

Groups come in this order. Leave a group out when the app has nothing for it; never fake one.

| # | Group | What goes in it | Example |
|---|---|---|---|
| 1 | **Account hero** | Only if the app signs in. Signed in: initials badge, the app's name ("Signed in to forVEX Build"), the email, Sign out, and **Delete account** when the app has sign-up. Signed out: a title, one line on what signing in gives you, the form. If the app offers Sign in with Apple, it goes first; it is required only when the app offers another third-party login (4.8), so email-only is fine. No section header: the hero is the header. | Build: Apple + email sign-in, Delete account beside Sign out |
| 2 | **Workspace** | Only if the app has shared workspaces. One collapsed row: the current workspace as the title, your role as the subtitle, a picker on tap. Members and invites live here too. | Build: workspace switch, Owner / Editor / Viewer |
| 3 | **Security** | App lock (Face ID / Touch ID / passcode), anything that hides content (app switcher, Spotlight), saved signatures. | Scan: Require Face ID, My Signature |
| 4 | **App choices** | The few choices that change what the app does day to day. One section per topic, named for the job, not the tech. Choice cards are allowed here (see Rules). **AI features** sit here as their own section. **Appearance**, if the app supports light mode, is the last section of this group. | Scan: New scans, AI summaries. Build: Estimating defaults, Rehab rates, AI features, Appearance |
| 5 | **Plan** | Only if the app sells anything. Current plan and renewal date, Manage subscription (opens the App Store's sheet), Restore purchases. | Build: plan, Restore |
| 6 | **Other settings** | Sync, backup, integrations, notifications, defaults most people never touch. | Scan: Backup |
| 7 | **Your data** | Storage used, items waiting to upload, Recently Deleted or Archived, Export, **Erase this device's data** (name the device: "Erase this iPad's data"). Delete account goes here if it isn't in the hero. | Scan: all four |
| 8 | **About** | Version (build), Help and Support, Privacy Policy, Terms of Use, Contact, diagnostics (logs), and a footer saying where data goes. | Scan: all, plus the share-extension log |

## Rules

- **Tokens.** Core tokens only, through each app's components (see "Components by role").
  Toggles and sliders tint the accent. Destructive rows use `role: .destructive`. Messages go
  through the inline-message component.
- **Footers explain consequences**, in plain words: what leaves the phone, what a switch does,
  and **who it applies to** (this device, your account, or everyone in the workspace). Every
  section that sends data anywhere says so in its footer.
- **Say what a setting is not** when it could be confused with something nearby. Train: "How
  the microphone listens. This is not a coach." Build: "Estimating defaults are not your price
  book."
- **Choice cards** for a choice that changes the experience: one card per option with an icon,
  a title and one line on what it does, the selected one marked with the accent edge and a
  checkmark so it reads without colour. Plain picker rows stay right for small format choices.
- **Long groups collapse.** A choice with many options, or a group with more than about five
  rows, becomes one row that shows the current value as its subtitle. Tapping it either opens
  a detail screen or expands the choices in place (Train's Market); both are fine as long as the
  collapsed row shows the current value.
- **Appearance**, only if the app supports light mode: a plain picker with Match the device
  (default), Dark, Light. It applies to this device only; say so in the footer. A dark-only app
  (Train forces Dark in Info.plist) has no Appearance row.
- **Anything destructive asks first** with a confirmation that says what goes, what stays, and
  that it can't be undone.
- **Links** in About open the app's site (`<app>.forvex.app/support`, `/privacy`, `/terms`) and
  `mailto:` the contact address, with the outward arrow. Keep every user-facing link (support, privacy, terms, contact, and the links on paywall and
  consent screens) in one `AppLinks` enum. API hosts, sockets and other service endpoints
  belong in the app's config, not in `AppLinks`.
- **One contact address: `admin@forvex.app`** (Paul, 2026-11-28). Every app's Contact row,
  error messages, legal pages, site and App Store support details use it. Don't add per-app or
  `support@` addresses.
- **Version** reads `CFBundleShortVersionString (CFBundleVersion)` from the bundle, never a
  literal.
- **Public and private builds** share the layout. Private-only parts come through the
  integration seam, so the public build simply has no hero.

## Third-party AI consent

Required when any content goes to a cloud AI (App Review 5.1.2(i)).

- **Ask once, before anything is sent.** The first time the owner uses or turns on a cloud AI
  feature, a screen asks; nothing goes until they agree. Replacing a key already in use doesn't
  ask again.
- **The consent screen says:** who the provider is; each kind of data sent, one line each
  (photos, voice notes, typed text, addresses...); what is *not* sent (name, email, payment);
  how the provider handles it (training, retention); what happens when it is off; and a
  Privacy Policy link. Buttons: "Allow AI features" and "Not now".
- **Turning it off** is always one row away in App choices › AI features, showing On or Off.
- **AI-first apps.** Where the app's core job is AI (Train: every session is an AI coach),
  Off means that job can't start. The consent screen says so plainly ("Sessions need AI. With
  AI off you can't start a session."), "Not now" leaves the owner on a screen that explains how
  to turn it on, and nothing is sent until they agree. In other apps the consent screen says
  the rest of the app works without AI.
- **Where the answer lives.** An app with a server stores consent on the account, with a
  version number, and the server refuses AI calls without it; a local flag alone is not
  enough. A device-only app stores it on the device. Bump the version (and ask again) when
  what is sent changes.

## Deleting an account

The rules are in [`ACCOUNT_DELETION_STANDARD.md`](./ACCOUNT_DELETION_STANDARD.md); this
section covers only what Settings shows. Every app with sign-up offers it (App Review
5.1.1(v)); apps that only sign in to an account made elsewhere don't need it.

- **Where:** in the hero beside Sign out, or in Your data. Destructive style.
- **Two choices:** "Delete my `<app>` account" (default) and, whenever the first would keep
  the sign-in, "Delete my whole forVEX account". The screen says which app keeps the
  sign-in.
- **Preview from the server.** Show `core.rpc_account_deletion_plan(app, scope)` as it comes:
  what goes, whether the sign-in stays and why, workspaces you leave, a subscription that
  deleting doesn't cancel (with Manage subscription). When the delete can't run, show the
  server's reason instead of a Delete button. The app never words blockers itself.
- **Confirm on purpose:** type DELETE, then `core.rpc_delete_account(app, scope, 'DELETE')`.
- **Fail safe:** clear this device and sign out only once the server confirms. On failure keep
  everything, sign nothing out, and show an inline error with `admin@forvex.app`.
- **Sign in with Apple:** when the sign-in goes, get a fresh authorization code so the server
  can revoke Apple's tokens.

## iPad

Build is the first forVEX app on iPad; these rules come from it and Apple's iPad guidance.

- **One view, two layouts.** Branch on `horizontalSizeClass`, never on the device. On regular
  width, Settings is a `NavigationSplitView`: groups on the left, the selected detail on the
  right. Select the first item when Settings opens so the right column is never empty. On
  compact width (iPhone, Slide Over, narrow Split View) it collapses to a push stack.
- **Sheets, popovers, inline:**
  - Detail screens that edit several fields open in the right column, not a sheet.
  - Pickers with few options (Appearance, Workspace) are inline pickers or menus.
  - A short explanation next to a control is a popover or tip anchored to it.
  - Consent, paywall and Delete account are sheets sized `.presentationSizing(.form)`.
  - Destructive confirmations stay `confirmationDialog`, anchored to the row that asked (it
    shows as a popover there on iPad).
- **Readable width.** Forms and lists in the detail column cap at about 680 pt and centre;
  document-like screens (reports) at about 760 pt. Never stretch a text field or toggle row
  across a landscape 13-inch screen.
- **Keyboard.** ⌘, opens Settings. Save is `.keyboardShortcut(.defaultAction)`, Cancel is
  `.cancelAction`, Tab moves between fields, and every shortcut appears in the ⌘-hold list.
- **Pointer.** Tappable rows get `.hoverEffect(.highlight)`, cards `.hoverEffect(.lift)`, with
  the content shape matching the corner radius.
- **Multiple windows.** Settings state lives in the shared app model, so a change in one
  window shows in the others; a Settings window on its own (Stage Manager) still works.
- **Choice cards** sit two or three across on regular width, one per row on compact.
- **Check** portrait, landscape, one-third Split View, small Stage Manager window, keyboard
  and trackpad attached, and the largest Dynamic Type size.

## Components by role

Name the role in new docs and reviews, not one app's symbols. Each app builds it from the same
Core tokens; until the shared core settles on one set of names, these are the equivalents.

| Role | reScan | forVEX Train | forVEX Build |
|---|---|---|---|
| Colours and type | `FV.*`, `.fvFont`, `.fvIcon` | `corePalette` | `corePalette`, Core fonts |
| Screen header | `FVScreenHeader` | Train's header | system large title (to align) |
| Card row / card | `FV.card` row background, `.fvCard()` | `CoreCard` | `CoreCard`, `.coreCanvas()` |
| Buttons | `FVPrimaryButtonStyle`, `FVSecondaryButtonStyle`, `FVIconButton` | `CoreButton` | `CoreButton` |
| Badge | | | `CoreBadge` |
| Inline message (error, warning, success) | `FVInlineMessage` | `CoreAlert` | none yet (`.coreDangerText()`); take `CoreAlert` |
| Confirmation | SwiftUI `confirmationDialog` | `CoreDialog` | `confirmationDialog` |

Settling on one name per role belongs in `reecosystem-core` with the tokens.

## What App Review needs (checked 2026-11-28)

| Item | Needed? | Why |
|---|---|---|
| Privacy policy link | **Yes**, in App Store Connect and reachable inside the app | 5.1.1(i). About › Privacy Policy covers the in-app part; a link only on a paywall or consent screen isn't enough. |
| Support URL | **Yes**, in App Store Connect | Required metadata. About › Help and Support links the same page. |
| Terms of use | **Yes with subscriptions** (3.1.2), else optional | Apple's standard EULA applies when you don't supply one. Paid apps link Terms on the paywall and in About. |
| Restore purchases | **Yes** for apps that sell non-consumables or subscriptions | Plan › Restore purchases. |
| Account deletion | **Only if the app lets people create an account** (5.1.1(v)) | See "Deleting an account". |
| Delete all data | **Not required** for data kept only on the device | We add Erase this device's data anyway: cheap, reviewers like it, and it answers "how do I delete my data". |
| Consent before third-party AI | **Yes** when content goes to a cloud AI | 5.1.2(i). See "Third-party AI consent". |

Paul owns the App Store Connect side: privacy and support URLs, the support email
(`admin@forvex.app`), the App Privacy answers, and the age rating.
