# Personal Homebrew tap conventions

This is a personal tap (`dpep/homebrew-tools`) — push directly to `main`, no PRs.

## Adding a formula

1. Look at existing files in `Formula/` for the source language closest to the project at hand.
2. Copy the install pattern from a sibling.
3. Write a real `test do` block — `--version` is a sanity check; add at least one functional assertion that exercises the CLI end-to-end.

## Description

Use the source project's existing tagline (often in the README's lead sentence or the gemspec/cargo manifest). Drop the trailing period (Homebrew convention). Keep it consistent with what the project advertises — if you change one, change the other.

## Commit style

Subject = formula name, lowercase, no prefix. Body = short description of what it is. Match recent commits in `git log --oneline`.

## Install patterns by language

- **Ruby gems** (`tztr.rb`): `depends_on "ruby"`, then `gem build` + `gem install` into `libexec`, then shim the executable with `write_env_script` so it picks up the right Ruby.
- **Go binaries** (`iriq.rb`): `depends_on "go" => :build` (Go is only needed during the build; the resulting binary is statically linked). Install with `system "go", "build", *std_go_args(output: bin/"iriq", ldflags: "-s -w"), "./cmd/iriq"`. No runtime deps.
- **Other languages**: add a new formula and document the pattern here.

When a project ships both Ruby and Go implementations, prefer the Go binary — faster startup, no runtime deps, simpler formula.

## Anti-patterns

- Don't pin a commit SHA in `url` — the tap uses `branch: "main"` so `brew upgrade` follows main.
- Don't add `revision` (used for rebuilds without a version bump; not needed for a personal tap).
- For Ruby gems: no `resource` blocks for runtime deps — `gem install` pulls them in via the gemspec.
- For Go binaries: don't `depends_on "go"` (runtime); always `=> :build`.

## Local install for testing

The README documents the symlink pattern (`ln -s ~/code/lib/homebrew-tools \`brew --repo\`/Library/Taps/dpep/homebrew-tools`, then `brew install dpep/tools/<formula>`). Don't run these unprompted — they touch the system Homebrew install.
