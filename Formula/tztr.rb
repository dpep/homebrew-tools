class Tztr < Formula
  desc "Timezone Translator"
  homepage "https://github.com/dpep/tztr"
  url "https://github.com/dpep/tztr.git", branch: "main"
  version "0.1.0"
  license "MIT"

  depends_on "rust" => :build

  def install
    # rust/tztr is one crate: library + `tztr` CLI binary. Timezone math uses
    # jiff against the system tz database (no bundled tzdata).
    system "cargo", "install", *std_cargo_args(path: "rust/tztr")
  end

  test do
    assert_match(/\A\d+\.\d+\.\d+\z/, shell_output("#{bin}/tztr --version").strip)
    assert_equal "2026-04-03T05:00:00-07:00",
                 pipe_output("#{bin}/tztr -t America/Los_Angeles",
                             "2026-04-03T12:00:00Z\n").strip
  end
end
