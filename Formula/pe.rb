class Pe < Formula
  desc "Programming by example for regexes and globs"
  homepage "https://github.com/dpep/pattern_engine"
  url "https://github.com/dpep/pattern_engine/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "635ebf2dd546e319f75375c03510644082e4bac40209fb65d25942cb3f9ac520"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match(/^pe \d+\.\d+\.\d+$/, shell_output("#{bin}/pe --version").strip)

    # read examples and emit the tightest matching pattern end-to-end
    (testpath/"ex.txt").write "ORD-1001\nORD-99\nORD-7\n"
    assert_equal "ORD-\\d+", shell_output("#{bin}/pe #{testpath}/ex.txt").strip

    # a counter-example tightens the result instead of over-generalizing
    (testpath/"keep.txt").write "a.log\nb.txt\n"
    (testpath/"reject.txt").write "c.bak\n"
    out = shell_output("#{bin}/pe #{testpath}/keep.txt -v #{testpath}/reject.txt").strip
    assert_equal "\\w+\\.(log|txt)", out
  end
end
