class DpepCommon < Formula
  desc "Common utilities"
  homepage "https://github.com/dpep/homebrew-tools/blob/main/README.md"
  url "https://github.com/dpep/homebrew-tools.git", branch: "main"
  version "0.0.1"
  license "MIT"

  %w[
    bash
    direnv
    ffmpeg
    gcc
    gh
    git
    go
    gpg
    jemalloc
    jq
    mysql-client
    pipenv
    postgresql@14
    rbenv
    readline
    redis
    ripgrep
    ruby
    rsync
    sqlite
    tree
    watch
    wget
  ].each do |dependency|
    depends_on dependency
  end

  GEMS = %w[
    bundler
    ruby-lsp
    ruby-lsp-rspec
    irbrc
    rekey
    rspec
  ]

  CASKS = %w[
    flux
    jumpcut
    visual-studio-code
  ]

  def post_install
    puts "Next steps:\n\n"

    puts "brew install --cask #{CASKS.join(" ")}"
    puts
    puts "open -a Flux"
    puts "open -a Jumpcut"

    puts "gem install #{GEMS.join(" ")}"
    puts
  end

end
