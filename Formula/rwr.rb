class Rwr < Formula
  desc "Ruby structural search and rewrites"
  homepage "https://github.com/dpep/rwr"
  url "https://github.com/dpep/rwr/archive/refs/tags/v0.6.7.tar.gz"
  sha256 "c0b514136cc0bd4a62210fcaaf20ba1bfb3f10f989ecc29c01028960178d5c68"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    # `rwr --completions bash|zsh` prints the completion script; Homebrew drops
    # it into the per-shell dirs so tab completion works after install.
    generate_completions_from_executable(bin/"rwr", "--completions", shells: [:bash, :zsh])
  end

  test do
    assert_match(/^rwr \d+\.\d+\.\d+$/, shell_output("#{bin}/rwr --version").strip)
    assert_match "complete -F _rwr", shell_output("#{bin}/rwr --completions bash")

    # structural find end-to-end: matches the expression as code
    (testpath/"widget.rb").write "def check\n  return nil\nend\n"
    assert_match "widget.rb:2", shell_output("#{bin}/rwr 'return nil' #{testpath}")
  end
end
