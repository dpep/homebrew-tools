class IriqSqlite < Formula
  desc "IRI extraction, normalization, and clustering (SQLite backend)"
  homepage "https://github.com/dpep/iriq"
  url "https://github.com/dpep/iriq.git", branch: "main"
  version "0.11.0"
  license "MIT"

  depends_on "go" => :build

  conflicts_with "iriq",
    because: "iriq-sqlite provides the same binary with the SQLite backend enabled"

  def install
    system "go", "build",
           *std_go_args(output: bin/"iriq", ldflags: "-s -w"),
           "-tags", "sqlite",
           "./cmd/iriq"
  end

  def caveats
    <<~EOS
      iriq-sqlite installs the same `iriq` binary as the iriq formula, but with the
      SQLite corpus backend compiled in (.db / .sqlite / .sqlite3 paths). To switch
      between builds:

        brew uninstall iriq && brew install iriq-sqlite
        # or
        brew uninstall iriq-sqlite && brew install iriq
    EOS
  end

  test do
    assert_match(/\A\d+\.\d+\.\d+\z/, shell_output("#{bin}/iriq --version").strip)
    assert_match "Build: sqlite", shell_output("#{bin}/iriq --help")
  end
end
