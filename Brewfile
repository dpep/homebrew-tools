# Brewfile — reproduce my dev setup on a new machine in one command.
#
#   brew bundle --file Brewfile                  # from a local clone
#
# or, with nothing cloned yet, straight from this repo (--file=- reads stdin;
# brew bundle has no URL flag, so pipe the raw file in):
#
#   curl -fsSL https://raw.githubusercontent.com/dpep/homebrew-tools/main/Brewfile | brew bundle --file=-
#
# Ruby gems aren't a Brewfile concept — run ./bootstrap.sh to also install those.

tap "dpep/tools"

# My CLIs (from the tap)
brew "dpep/tools/rq"
brew "dpep/tools/navi"
brew "dpep/tools/ae"
brew "dpep/tools/iriq"
brew "dpep/tools/pe"
brew "dpep/tools/launder"
brew "dpep/tools/tztr"

# Common tools
brew "bash"
brew "direnv"
brew "ffmpeg"
brew "gcc"
brew "gh"
brew "git"
brew "go"
brew "gpg"
brew "jemalloc"
brew "jq"
brew "mysql-client"
brew "pipenv"
brew "postgresql@14"
brew "rbenv"
brew "readline"
brew "redis"
brew "ripgrep"
brew "ruby"
brew "rsync"
brew "sqlite"
brew "tree"
brew "watch"
brew "wget"

# GUI apps
cask "flux"
cask "jumpcut"
cask "visual-studio-code"
