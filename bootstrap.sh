#!/bin/sh
# New-machine setup: install the Brewfile (tap + CLIs + formulae + casks), then
# the Ruby gems a Brewfile can't express. Idempotent — re-run any time.
#   curl -fsSL https://raw.githubusercontent.com/dpep/homebrew-tools/main/bootstrap.sh | sh
set -eu
curl -fsSL https://raw.githubusercontent.com/dpep/homebrew-tools/main/Brewfile | brew bundle --file=-
gem install bundler irbrc rekey rspec
open -a Flux
open -a Jumpcut
