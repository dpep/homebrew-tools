class Rq < Formula
  desc "Reference Query — find the code you're looking for"
  homepage "https://github.com/dpep/rq"
  url "https://github.com/dpep/rq/archive/refs/tags/v0.31.1.tar.gz"
  sha256 "d86312c3c1c8f71e8a513ecee1f8c6b5a14d1ea507e1131b7d543b582bf20ae3"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    # `rq --completions bash|zsh` prints the completion script; Homebrew drops it
    # into the per-shell dirs so tab completion works after install.
    generate_completions_from_executable(bin/"rq", "--completions", shells: [:bash, :zsh])
  end

  test do
    assert_match(/^rq \d+\.\d+\.\d+$/, shell_output("#{bin}/rq --version").strip)
    assert_match "complete -F _rq", shell_output("#{bin}/rq --completions bash")

    # index a tiny repo (Ruby + Rust) and find the definitions end-to-end
    ENV["RQ_DB"] = "#{testpath}/rq.db"
    (testpath/"widget.rb").write "class Widget\nend\n"
    (testpath/"gadget.rs").write "pub struct Gadget {}\n"
    system bin/"rq", "--index", testpath
    # rq searches the current repo, so run it from inside the indexed tree
    cd testpath do
      assert_match "Widget", shell_output("#{bin}/rq widget")
      assert_match "Gadget", shell_output("#{bin}/rq gadget -k struct")
    end
  end
end
