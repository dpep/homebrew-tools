class Tztr < Formula
  desc "Timezone Translator: convert timestamps between timezones"
  homepage "https://github.com/dpep/tztr"
  url "https://github.com/dpep/tztr/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "49f90e3ed672559768b5219ecddae45b4ce89abcd6ad1d9a66af8320818888c7"
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
