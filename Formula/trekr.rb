class Trekr < Formula
  desc "Ruby code intelligence — position to meaning, definition to references"
  homepage "https://github.com/dpep/trekr"
  url "https://github.com/dpep/trekr/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "ec283023bfd38e66b74784748f83742553ae89028d04dea03424aae0423daed8"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    # `trekr --completions bash|zsh` prints the completion script; Homebrew drops
    # it into the per-shell dirs so tab completion works after install.
    generate_completions_from_executable(bin/"trekr", "--completions", shells: [:bash, :zsh])
  end

  test do
    assert_match(/^trekr \d+\.\d+\.\d+$/, shell_output("#{bin}/trekr --version").strip)
    assert_match "complete -F _trekr", shell_output("#{bin}/trekr --completions bash")

    # Facts are keyed by git blob OID, so the tree under test has to be a real
    # checkout — a plain directory is refused with exit 2, by design.
    ENV["TREKR_DB"] = "#{testpath}/trekr.db"
    # A call site, not just a definition: `--refs` reports "no references" with
    # exit 1 when a method is only ever defined, which is the honest answer but
    # not a smoke test.
    (testpath/"widget.rb").write <<~RUBY
      class Widget
        def resize(width)
        end
      end

      Widget.new.resize(2)
    RUBY
    system "git", "-C", testpath, "init", "-q"
    system "git", "-C", testpath, "add", "-A"
    system "git", "-C", testpath, "-c", "user.email=t@e.st", "-c", "user.name=test",
           "commit", "-qm", "init"

    system bin/"trekr", "--index", testpath
    cd testpath do
      assert_match "Widget", shell_output("#{bin}/trekr --symbols widget.rb")

      # The definition plus the call site, tiered by receiver — the whole point
      # of --refs over a grep.
      refs = shell_output("#{bin}/trekr --refs Widget#resize")
      assert_match "definition", refs
      assert_match "possible", refs
    end
  end
end
