class Driftr < Formula
  desc "Automatic, recoverable working history for AI-assisted development"
  homepage "https://github.com/dpep/driftr"
  url "https://github.com/dpep/driftr/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "b065d6d48dd4edf6d47e46f63f91c7ea24045e46a601844bd3edee021244eff7"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match(/^driftr \d+\.\d+\.\d+$/, shell_output("#{bin}/driftr --version").strip)

    # snapshot a file, change it, and get the old version back
    system "git", "init", "-q"
    (testpath/"plan.md").write "first\n"
    system bin/"driftr", "snapshot"
    File.write testpath/"plan.md", "second\n"
    system bin/"driftr", "snapshot"
    assert_equal "first\n", shell_output("#{bin}/driftr show @~1 plan.md")
    system bin/"driftr", "restore", "plan.md", "--at", "@~1"
    assert_equal "first\n", (testpath/"plan.md").read
  end
end
