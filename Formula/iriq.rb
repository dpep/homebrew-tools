class Iriq < Formula
  desc "IRI extraction, normalization, and clustering"
  homepage "https://github.com/dpep/iriq"
  url "https://github.com/dpep/iriq.git", branch: "main"
  version "0.29.1"
  license "MIT"

  depends_on "rust" => :build

  def install
    # The CLI crate (rust/iriq-cli) pins the `sqlite` feature on its `iriq`
    # dependency, so every build ships the SQLite corpus backend (.db /
    # .sqlite / .sqlite3) via rusqlite's bundled C SQLite — no build tags,
    # no second formula.
    system "cargo", "install", *std_cargo_args(path: "rust/iriq-cli")

    # `iriq completion bash|zsh` emits the shell completion scripts; Homebrew
    # drops them into the per-shell dirs so tab completion works after install.
    generate_completions_from_executable(bin/"iriq", "completion", shells: [:bash, :zsh])
  end

  test do
    assert_match(/\A\d+\.\d+\.\d+\z/, shell_output("#{bin}/iriq --version").strip)
    assert_equal "https://foo.com/users/{user_id}",
                 shell_output("#{bin}/iriq -n https://foo.com/users/123").strip
    assert_match(/^complete -F _iriq iriq$/, shell_output("#{bin}/iriq completion bash"))

    # SQLite ships in every build — exercise a .db corpus round-trip.
    system bin/"iriq", "--corpus", "#{testpath}/c.db", "https://foo.com/users/1"
    assert_match "observations", shell_output("#{bin}/iriq --corpus #{testpath}/c.db --stats")
  end
end
