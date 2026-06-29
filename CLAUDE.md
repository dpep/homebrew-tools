# Personal Homebrew tap conventions

This is a personal tap (`dpep/homebrew-tools`) — push directly to `main`, no PRs.

## Adding a formula

1. Look at existing files in `Formula/` for the source language closest to the project at hand.
2. Copy the install pattern from a sibling.
3. Pin to a **release tag** with a `sha256` (see below) — not `branch: "main"`.
4. Write a real `test do` block — `--version` is a sanity check; add at least one functional assertion that exercises the CLI end-to-end.

## Release-tagged formulas (the norm)

Formulae pin to a checksummed release tarball, not a moving branch. This makes
every install reproducible and keeps each formula **homebrew-core-ready** (core
rejects `branch:`/`HEAD`-only formulae — it requires a versioned archive + a
`sha256`). The shape:

```ruby
url "https://github.com/dpep/<repo>/archive/refs/tags/v<X.Y.Z>.tar.gz"
sha256 "<64-hex>"
# no `version` line — Homebrew derives it from the tag in the URL
# no `branch:` / `tag:` / `revision:`
```

Tag convention is `vX.Y.Z` (with the `v`). Releasing / bumping a formula is then:

1. In the source repo, bump the crate/gem version, commit, and push `main`.
2. Tag and push: `git -C <repo> tag -a vX.Y.Z -m vX.Y.Z && git -C <repo> push origin vX.Y.Z`.
3. Compute the archive checksum — GitHub's tag tarball is stable:
   `curl -sL https://github.com/dpep/<repo>/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256`
4. Update the formula's `url` (new tag) and `sha256`, then commit + push the tap.
5. Sanity-check before pushing: `brew style Formula/<name>.rb` and, to confirm
   the version parses, `brew ruby -e 'puts Version.detect("<url>").to_s'`.

A monorepo crate in a subdir keeps its `std_cargo_args(path: "rust/<name>")` —
the path is relative to the extracted archive root, same as before. Confirm the
crate path actually exists *at that tag* (`tar tzf … | grep rust/<name>/Cargo.toml`)
before pinning: an old tag may predate a layout change.

To upgrade a release-tagged install after pushing the tap:
`brew upgrade dpep/tools/<name>` (always fully-qualify — see the name-collision
note below). No `--fetch-HEAD` dance; the new tag is a new download.

## New-machine setup lives in the Brewfile, not a formula

The "install all my common tools" bundle is [`Brewfile`](Brewfile) + [`bootstrap.sh`](bootstrap.sh), driven by `brew bundle` — not a meta-formula. A formula can't depend on casks or install gems, and `brew bundle` natively handles taps + formulae + casks together (gems are a `bootstrap.sh` follow-up). Remote one-liner for a fresh box: `curl -fsSL .../main/Brewfile | brew bundle --file=-`. When adding a new tool to the tap that belongs in the default setup, add a `brew "dpep/tools/<name>"` line to the Brewfile too. (This replaced the old `dpep-common` meta-formula.)

## Description

Use the source project's existing tagline (often in the README's lead sentence or the gemspec/cargo manifest). Drop the trailing period (Homebrew convention). Keep it consistent with what the project advertises — if you change one, change the other.

## Commit style

Subject = formula name, lowercase, no prefix. Body = short description of what it is. Match recent commits in `git log --oneline`.

## Install patterns by language

- **Ruby gems** (`tztr.rb`): `depends_on "ruby"`, then `gem build` + `gem install` into `libexec`, then shim the executable with `write_env_script` so it picks up the right Ruby.
- **Go binaries** (`iriq.rb`): `depends_on "go" => :build` (Go is only needed during the build; the resulting binary is statically linked). Install with `system "go", "build", *std_go_args(output: bin/"iriq", ldflags: "-s -w"), "./cmd/iriq"`. No runtime deps.
- **Rust binaries** (`rq.rb`): `depends_on "rust" => :build` (build-time only; the
  binary is built on demand, not pre-packaged). Install with
  `system "cargo", "install", *std_cargo_args` — `std_cargo_args` expands to
  `--locked --root #{prefix} --path .`, so the crate's committed `Cargo.lock` is
  honored and the binary lands in `bin/`. No runtime deps.
- **Other languages**: add a new formula and document the pattern here.

When a project ships both Ruby and Go implementations, prefer the Go binary — faster startup, no runtime deps, simpler formula.

## Sibling formulas sharing a source

When two formulae build the same upstream repo (different build flags/features), bump them together to the same release tag — version skew between siblings that share a source is wrong.

## Anti-patterns

- Don't use `branch: "main"` (or `tag:`/`commit:` on a `.git` url) for new or updated formulae — pin to a checksummed release-tag tarball (see "Release-tagged formulas"). Branch-tracking ships whatever's on main under a possibly-stale version number, isn't reproducible, and is rejected by homebrew-core. A few un-migrated formulae may still track `main`; convert them when next touched.
- Don't keep a redundant `version` line when the tag is in the `url` — Homebrew derives the version from it.
- Don't add `revision` (used for rebuilds without a version bump; not needed for a personal tap).
- For Ruby gems: no `resource` blocks for runtime deps — `gem install` pulls them in via the gemspec.
- For Go binaries: don't `depends_on "go"` (runtime); always `=> :build`.

## Local install for testing

The README documents the symlink pattern (`ln -s ~/code/lib/homebrew-tools \`brew --repo\`/Library/Taps/dpep/homebrew-tools`, then `brew install dpep/tools/<formula>`). Don't run these unprompted — they touch the system Homebrew install.
