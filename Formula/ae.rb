class Ae < Formula
  desc "Acronym extraction and expansion engine, local-first"
  homepage "https://github.com/dpep/ae"
  url "https://github.com/dpep/ae.git", branch: "main"
  version "0.2.0"
  license "MIT"

  depends_on "rust" => :build
  # ONNX Runtime powers the embedding model. ae loads it dynamically at runtime
  # (the `ort-load-dynamic` build), so there's no build-time linking/download —
  # ae probes the keg for the dylib on startup.
  depends_on "onnxruntime"

  # The embedding model (all-MiniLM-L6-v2, int8-quantized) is fetched at build
  # time upstream and never committed. Homebrew downloads it out-of-band here,
  # checksummed, and we install it where ae's default search path finds it.
  resource "model" do
    url "https://huggingface.co/Xenova/all-MiniLM-L6-v2/resolve/main/onnx/model_quantized.onnx"
    sha256 "afdb6f1a0e45b715d0bb9b11772f032c399babd23bfc31fed1c170afc848bdb1"
  end

  resource "tokenizer" do
    url "https://huggingface.co/Xenova/all-MiniLM-L6-v2/resolve/main/tokenizer.json"
    sha256 "da0e79933b9ed51798a3ae27893d3c5fa4a201126cef75586296df9b4d2c62a0"
  end

  def install
    # Skip ae's own build-time model fetch (no sandbox network) — we install the
    # model below. ONNX Runtime is dlopen'd at runtime, so nothing to link here.
    ENV["AE_SKIP_MODEL_DOWNLOAD"] = "1"
    system "cargo", "install", *std_cargo_args, "--no-default-features", "--features", "ort-load-dynamic"

    # Install the model under ae's default search dir
    # (<prefix>/share/ae/models/<name>), found automatically at runtime.
    model_dir = share/"ae/models/all-MiniLM-L6-v2-quantized"
    model_dir.mkpath
    resource("model").stage { model_dir.install "model_quantized.onnx" => "model.onnx" }
    resource("tokenizer").stage { model_dir.install "tokenizer.json" }
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
