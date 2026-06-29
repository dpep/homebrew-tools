class Ae < Formula
  desc "Acronym extraction and expansion engine"
  homepage "https://github.com/dpep/ae"
  url "https://github.com/dpep/ae/archive/refs/tags/v0.5.3.tar.gz"
  sha256 "d93ea08cc4b2755dc24527790cea3e621d4c1707a877463d031095e716daf17d"
  license "MIT"

  depends_on "rust" => :build
  # ONNX Runtime powers the embedding model. ae loads it dynamically at runtime
  # (the `ort-load-dynamic` build), so there's no build-time linking/download —
  # ae probes the keg for the dylib on startup.
  depends_on "onnxruntime"

  def install
    # ONNX Runtime is dlopen'd at runtime, so nothing to link here. The
    # embedding model is fetched on first use from the HuggingFace Hub into the
    # shared cache (~/.cache/huggingface/hub) — nothing to install here either.
    system "cargo", "install", *std_cargo_args, "--no-default-features", "--features", "ort-load-dynamic"
  end

  test do
    assert_match(/^ae \d+\.\d+\.\d+$/, shell_output("#{bin}/ae --version").strip)

    # End-to-end: pipe text and confirm a seeded acronym expands and an inline
    # definition is learned.
    cmd = "#{bin}/ae --socket #{testpath}/ae.sock --db #{testpath}/ae.db -j"
    out = pipe_output(cmd, "The KPI (Key Performance Indicator) feeds the OKR review.")
    assert_match "Objectives and Key Results", out
    assert_match "Key Performance Indicator", out
  end
end
