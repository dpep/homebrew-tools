class Launder < Formula
  desc "Make logs pastesafe"
  homepage "https://github.com/dpep/launder"
  url "https://github.com/dpep/launder/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "569a536c5812739d33ca013a3e9df7b1ec3b0d7ccc2125eb03ebf96c041b8e8b"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match(/^launder \d+\.\d+\.\d+$/, shell_output("#{bin}/launder --version").strip)

    # zero-config: a home path collapses to ~ while the tail is preserved
    out = pipe_output("#{bin}/launder", "/Users/dpep/code/proj/src/db.rs:42\n")
    assert_equal "~/code/proj/src/db.rs:42", out.strip

    # secrets are always redacted, and never reappear in JSON output
    json = pipe_output("#{bin}/launder -j --with-originals", "ghp_AbCdEf0123456789\n")
    assert_match "<TOKEN_1>", json
    refute_match "ghp_AbCdEf0123456789", json
  end
end
