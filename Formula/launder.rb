class Launder < Formula
  desc "Share logs safely"
  homepage "https://github.com/dpep/launder"
  url "https://github.com/dpep/launder/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "012d1efd4fd4585ce01f0432c9e312e58dd98aa546175d9192e39811c365ac11"
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
