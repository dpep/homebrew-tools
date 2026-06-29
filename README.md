# Homebrew Tools

The goal is to make setting up your dev environment easy, awesome, and repeatable.


## New machine setup

One command from a fresh machine (with Homebrew already installed) — installs the
tap, every CLI, the common formulae, and the GUI casks. `brew bundle` has no URL
flag, so pipe the raw [`Brewfile`](Brewfile) in via stdin (`--file=-`):

```shell
curl -fsSL https://raw.githubusercontent.com/dpep/homebrew-tools/main/Brewfile | brew bundle --file=-
```

Then the Ruby gems (not a Brewfile concept):

```shell
gem install bundler ruby-lsp ruby-lsp-rspec irbrc rekey rspec
```

Or clone this repo and run [`./bootstrap.sh`](bootstrap.sh) to do both in one shot.
Re-running either is safe — it just installs whatever's missing.


## How do I install these formulae?

```shell
brew install dpep/tools/<formula>


# or
brew tap dpep/tools
brew install <formula>
```


## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).


## Local Development

Create symlink to Taps directory
```shell
ln -s /path/to/local/homebrew-tools `brew --repo`/Library/Taps/dpep/homebrew-tools
```

Install local formula
```shell
brew install dpep/tools/<formula>
```

Lint changes
```shell
brew audit --eval-all
```

Resources
- https://docs.brew.sh/Formula-Cookbook
