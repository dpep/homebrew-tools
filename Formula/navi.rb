class Navi < Formula
  desc "Semantic filesystem operations for AI coding agents"
  homepage "https://github.com/dpep/navi"
  url "https://github.com/dpep/navi.git", branch: "main"
  version "0.11.0"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      To expose navi's commands as MCP tools inside Claude Code, register the
      server (user scope, all projects):
        claude mcp add --scope user navi -- navi mcp

      Or run the bundled helper, which does the same thing:
        navi install
    EOS
  end

  test do
    assert_match(/^navi \d+\.\d+\.\d+$/, shell_output("#{bin}/navi --version").strip)

    # locate finds content end-to-end, emitting the result envelope
    ENV["NAVI_DATA_DIR"] = "#{testpath}/state"
    (testpath/"widget.rs").write "fn needle() {}\n"
    cd testpath do
      out = shell_output("#{bin}/navi locate --match text needle")
      assert_match "\"ok\": true", out
      assert_match "needle", out
    end
  end
end
