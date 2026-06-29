#!/usr/bin/env bash
# Set up a new machine in one shot: everything in the Brewfile, then the gems
# (which a Brewfile can't express). Idempotent — safe to re-run any time.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

brew bundle --file "$here/Brewfile"

gem install bundler ruby-lsp ruby-lsp-rspec irbrc rekey rspec

echo
echo "Done. GUI apps installed via cask: Flux, Jumpcut, VS Code."
