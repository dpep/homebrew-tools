class Contour < Formula
  desc "Semantic index of source code — search, navigate and dedupe by intent"
  homepage "https://github.com/dpep/contour"
  url "https://github.com/dpep/contour/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "62f0b70fa7a9516b4a345a551ad5418bba99ddf17428f130cb4621207231195f"
  license "MIT"

  depends_on "rust" => :build
  # English search runs all-MiniLM-L6-v2 through ONNX Runtime, dlopen'd at
  # runtime (the `semantic-dynamic` build) — no build-time download or static
  # linking, and it shares the keg with `ae`. The model itself is
  # fetched on first use into ~/.cache/huggingface/hub.
  depends_on "onnxruntime"

  def install
    # No `--no-default-features`: contour's default feature set is empty, and a
    # default build silently falls back to the hash embedder, which matches on
    # names rather than meaning.
    system "cargo", "install", *std_cargo_args, "--features", "semantic-dynamic"

    generate_completions_from_executable(bin/"contour", "--completions")
  end

  test do
    # `--version` reports the embedder, which is the only difference between two
    # builds of the same commit — a hash-embedder build here is a broken install.
    version_output = shell_output("#{bin}/contour --version")
    assert_match(/^contour \d+\.\d+\.\d+$/, version_output.lines.first.strip)
    assert_match "embedder: onnx embedder, dlopened from a system ONNX Runtime", version_output

    assert_match "complete -F _contour", shell_output("#{bin}/contour --completions bash")

    # `--symbols` outlines a file without touching an index, so the smoke test
    # needs no database, no git checkout and no model download.
    (testpath/"widget.rb").write <<~RUBY
      class Widget
        def resize(width)
        end
      end
    RUBY
    symbols = shell_output("#{bin}/contour --symbols #{testpath}/widget.rb")
    assert_match "Widget", symbols
    assert_match "resize", symbols
  end
end
