class Rq < Formula
  desc "Code navigation engine — reach the definition you want, fast"
  homepage "https://github.com/dpep/rq"
  url "https://github.com/dpep/rq.git", branch: "main"
  version "0.1.0"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match(/^rq \d+\.\d+\.\d+$/, shell_output("#{bin}/rq --version").strip)

    # index a tiny repo and find the definition end-to-end
    ENV["RQ_DB"] = "#{testpath}/rq.db"
    (testpath/"widget.rb").write "class Widget\nend\n"
    system bin/"rq", "--index", testpath
    assert_match "Widget", shell_output("#{bin}/rq -C #{testpath} widget")
  end
end
