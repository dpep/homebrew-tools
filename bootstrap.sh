#!/usr/bin/env bash
# Set up a new machine in one shot: everything in the Brewfile, then the gems
# (which a Brewfile can't express). Idempotent — safe to re-run any time.
#
# Run it either way:
#   ./bootstrap.sh                                                   # from a clone
#   curl -fsSL https://raw.githubusercontent.com/dpep/homebrew-tools/main/bootstrap.sh | bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/dpep/homebrew-tools/main"

# Use the Brewfile sitting next to this script when run from a clone; when piped
# via `curl | bash` there's no local file, so fetch it from the repo.
src="${BASH_SOURCE[0]:-}"
here=""
[[ -n "$src" ]] && here="$(cd "$(dirname "$src")" 2>/dev/null && pwd || true)"

if [[ -n "$here" && -f "$here/Brewfile" ]]; then
  brew bundle --file "$here/Brewfile"
else
  curl -fsSL "$REPO_RAW/Brewfile" | brew bundle --file=-
fi

gem install bundler irbrc rekey rspec

echo
echo "Done. GUI apps installed via cask: Flux, Jumpcut, VS Code."
