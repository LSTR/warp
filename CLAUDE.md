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

## Building
```bash
./script/bootstrap   # first-time setup
./script/run         # build and run
./script/presubmit   # fmt + clippy + tests before committing
```

Bundle the lightweight personal app:
```bash
cargo bundle --bin warp-lstr --no-default-features --features lstr
```

Output lands in `target/debug/bundle/osx/WarpLstr.app` — copy to `/Applications/` to install alongside the main Warp app.

To build the full OSS build instead:
```bash
cargo bundle --bin warp-oss
```

## App identity
This fork builds as **WarpLstr** (`dev.warp.WarpLstr`) so it installs and runs independently from the official Warp app.

## Customizations on this branch
- App renamed to WarpLstr (bundle identifier: `dev.warp.WarpLstr`)
