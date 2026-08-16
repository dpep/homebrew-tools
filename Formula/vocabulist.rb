class Vocabulist < Formula
  desc "Live personal dictionary, learned from the words you actually use"
  homepage "https://github.com/dpep/vocabulist"
  url "https://github.com/dpep/vocabulist/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "f0c9109d70fa6cba279a800586bfca6c9552a325e6234b68e04941c6aab61b03"
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
    system bin/"vocab", "capture", "-r", "slack", "we shipped the zblorg today"
    system bin/"vocab", "process"
    assert_equal "", shell_output("#{bin}/vocab -q 'zblorg shipped'")
  end
end
