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
cargo bundle --bin warp-lstr --no-default-features --features lstr
open ../target/debug/bundle/osx/WarpLstr.app
```

Output lands in `target/debug/bundle/osx/WarpLstr.app` (workspace root `target/`, not `app/target/`).

## Syncing the installed app after a rebuild
```bash
cp -r target/debug/bundle/osx/WarpLstr.app /Applications/
```

## Building the full OSS build instead
```bash
cd app
cargo bundle --bin warp-oss
```

## App identity
This fork builds as **WarpLstr** (`dev.warp.WarpLstr`) so it installs and runs independently from the official Warp app.

## Customizations on this branch
- App renamed to WarpLstr (bundle identifier: `dev.warp.WarpLstr`)
- Lightweight feature set: core terminal + multi-profile + light AI, no cloud/sentry/rquickjs
- Sign-up screen bypassed (`skip_login`, `skip_firebase_anonymous_user`)
- `ToggleConversationListView` menu item guarded by its feature flag to prevent startup crash
