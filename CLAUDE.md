# Warp — lstr personal fork

## Branch
Personal customizations live on the `lstr` branch. `master` tracks upstream.

## Syncing with upstream
```bash
git fetch upstream
git rebase upstream/master
```

If you haven't added the upstream remote yet:
```bash
git remote add upstream https://github.com/warpdotdev/warp.git
```

## Install (first time or after major changes)
Run from the repo root — handles all dependencies, builds, and copies to `/Applications/`:
```bash
./install.sh
```

## Rebuild and run (day-to-day)
Run from `app/` — skips dependency setup, just rebuilds and opens:
```bash
cd app
cargo bundle --bin lstr-warp --no-default-features --features lstr
open ../target/debug/bundle/osx/LstrWarp.app
```

Output lands in `target/debug/bundle/osx/LstrWarp.app` (workspace root `target/`, not `app/target/`).

## Syncing the installed app after a rebuild
Always re-sign after copying — see "Code signing" below.
```bash
cp -r target/debug/bundle/osx/LstrWarp.app /Applications/
codesign --force --identifier dev.warp.LstrWarp --timestamp=none \
  --sign "$(security find-identity -v -p codesigning | grep 'Apple Development' | head -1 | sed -E 's/.*"(.*)"$/\1/')" \
  /Applications/LstrWarp.app
```

## Code signing
`cargo bundle` leaves the app **ad-hoc (linker-signed)** with an unstable
identifier (`lstr_warp-<hash>`), so its cdhash changes on every build. macOS TCC
keys privacy grants to the signing identity, so an ad-hoc app looks like a new
app after each rebuild and **re-prompts for Documents/Desktop access every time**.

Signing with a real certificate makes the designated requirement
`identifier + certificate` instead of the cdhash, so grants persist:

```
designated => identifier "dev.warp.LstrWarp" and anchor apple generic
              and certificate leaf[subject.CN] = "Apple Development: ..."
```

`install.sh` does this automatically (override with `CODESIGN_ID=...`).
Verify with `codesign -dvvv /Applications/LstrWarp.app` — look for
`Signature=adhoc` (bad) vs an `Authority=` chain (good).

Caveat: the Apple Development cert expires **2027-01-15**. When it does, the
signature goes invalid and the prompts return — either renew it in Xcode or
create a long-lived self-signed code-signing cert in Keychain Access.
After changing signing identity, run `tccutil reset All dev.warp.LstrWarp`.

## Config location
LstrWarp runs as `Channel::Oss`, so its config lives in **`~/.warp-oss/`**,
not `~/.warp/` (that's the official Warp). Both are independent.
- `~/.warp-oss/settings.toml` — settings; directory tab colors use
  `"/abs/path" = { color = "cyan" }` (both lowercase, absolute paths only)
- `~/.warp-oss/tab_configs/*.toml` — per-project tab configs, surfaced as items
  in the `+` menu. Both hot-reload on save.

## Building the full OSS build instead
```bash
cd app
cargo bundle --bin warp-oss
```

## App identity
This fork builds as **LstrWarp** (`dev.warp.LstrWarp`) so it installs and runs independently from the official Warp app.

## Customizations on this branch
- App renamed to LstrWarp (bundle identifier: `dev.warp.LstrWarp`)
- Lightweight feature set: core terminal + multi-profile + light AI, no cloud/sentry/rquickjs
- Sign-up screen bypassed (`skip_login`, `skip_firebase_anonymous_user`)
- `ToggleConversationListView` menu item guarded by its feature flag to prevent startup crash
