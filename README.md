# Homebrew Tools

The goal is to make setting up your dev environment easy, awesome, and repeatable.


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
