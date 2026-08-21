class Vocabulist < Formula
  desc "Live personal dictionary, learned from the words you actually use"
  homepage "https://github.com/dpep/vocabulist"
  url "https://github.com/dpep/vocabulist/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "cdf18dbdc811ff6b8fc5ae68e860ff00451bd7c8f8ac42cb21532ad692f6fd73"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    # `vocab --completions bash|zsh` prints the completion script; Homebrew drops
    # it into the per-shell dirs so tab completion works after install.
    generate_completions_from_executable(bin/"vocab", "--completions", shells: [:bash, :zsh])
  end

  test do
    assert_match(/^vocab \d+\.\d+\.\d+$/, shell_output("#{bin}/vocab --version").strip)
    assert_match "complete -F _vocab", shell_output("#{bin}/vocab --completions bash")

    ENV["VOCAB_DB"] = "#{testpath}/lexicon.db"

    # A word in the lexicon is never flagged, and an unknown one is — the whole
    # premise, end to end. Exit 1 means findings, so shell_output expects it.
    system bin/"vocab", "add", "contextdb"
    assert_match "contextdb", shell_output("#{bin}/vocab list context")
    assert_equal "", shell_output("#{bin}/vocab -q contextdb")

    findings = shell_output("#{bin}/vocab -j 'zzzqxwv'", 1)
    assert_match "\"kind\": \"unknown\"", findings
    assert_match "\"word\": \"zzzqxwv\"", findings

    # Capture stages text; process folds it into counts and drops the prose.
    #
    # Asserts the word was recorded, not that it silences the checker: since
    # 0.5.0 a captured word needs sightings on two separate days before it is
    # trusted, because typos are bursty within one sitting. A smoke test
    # cannot wait a day, and should be testing the pipeline rather than the
    # threshold anyway.
    system bin/"vocab", "capture", "-r", "slack", "we shipped the zblorg today"
    system bin/"vocab", "process"
    assert_match "zblorg", shell_output("#{bin}/vocab list zblorg")
  end
end
