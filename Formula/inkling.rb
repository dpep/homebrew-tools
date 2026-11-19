class Inkling < Formula
  desc "Tells agents when a pull request, Jira issue or Slack message changes"
  homepage "https://github.com/dpep/inkling"
  url "https://github.com/dpep/inkling/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "763d43a0a51772b52def715192e4d3ac1174febe5bb92d87f11d0bc3a3657f1b"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match(/^inkling \d+\.\d+\.\d+$/, shell_output("#{bin}/inkling --version").strip)

    # Every path points into the sandbox, so nothing touches a real store.
    args = %W[
      --config #{testpath}/config.toml
      --state #{testpath}/state.json
      --watches #{testpath}/watches.json
      --log-dir #{testpath}/logs
    ]
    assert_match "watching nothing", shell_output("#{bin}/inkling #{args.join(" ")} watch")

    # A pull request link resolves to its canonical name; unwatching what was
    # never watched says so rather than failing.
    pr = "https://github.com/dpep/inkling/pull/1"
    assert_match "github.com/dpep/inkling#1: you aren't watching that",
                 shell_output("#{bin}/inkling #{args.join(" ")} unwatch #{pr}")
  end
end
