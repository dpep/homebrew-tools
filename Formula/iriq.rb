class Iriq < Formula
  desc "IRI extraction, normalization, and clustering"
  homepage "https://github.com/dpep/iriq"
  url "https://github.com/dpep/iriq/archive/refs/tags/v0.34.0.tar.gz"
  sha256 "72e6cf51b95982dc700d12c502e4588e3292be53abfd68963e20a389fade2923"
  license "MIT"

  depends_on "rust" => :build

  def install
    # rust/iriq is one crate: library + `iriq` CLI binary. It links SQLite
    # (rusqlite, bundled), so .db/.sqlite/.sqlite3 corpora just work.
    system "cargo", "install", *std_cargo_args(path: "rust/iriq")

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
