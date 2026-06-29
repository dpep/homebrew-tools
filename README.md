# Homebrew Tools

The goal is to make setting up your dev environment easy, awesome, and repeatable.


## New machine setup

One line on a fresh machine (with Homebrew already installed) — installs the tap,
every CLI, the common formulae, the GUI casks, and the Ruby gems:

```shell
curl -fsSL https://raw.githubusercontent.com/dpep/homebrew-tools/main/bootstrap.sh | bash
```

It runs `brew bundle` against the repo's [`Brewfile`](Brewfile), then `gem install`.
(`curl | bash` runs remote code — it's your repo, but give it a read first if you
like.)

Prefer it declarative, or want to skip the gems? Just the Brewfile — `brew bundle`
has no URL flag, so pipe it in via stdin (`--file=-`):

```shell
curl -fsSL https://raw.githubusercontent.com/dpep/homebrew-tools/main/Brewfile | brew bundle --file=-
```

Or clone this repo and run [`./bootstrap.sh`](bootstrap.sh). Re-running anything
here is safe — it just installs whatever's missing.


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
