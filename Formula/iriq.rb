class Iriq < Formula
  desc "IRI extraction, normalization, and clustering"
  homepage "https://github.com/dpep/iriq"
  url "https://github.com/dpep/iriq.git", branch: "main"
  version "0.28.0"
  license "MIT"

  depends_on "go" => :build

  conflicts_with "iriq-sqlite",
    because: "both install the same `iriq` binary"

  def install
    system "go", "build", *std_go_args(output: bin/"iriq", ldflags: "-s -w"), "./cmd/iriq"

    # `iriq completion bash|zsh` emits the shell completion scripts
    # (embedded into the binary from the iriq Go package). Homebrew
    # drops them into the per-shell completion dirs so tab completion
    # works automatically after `brew install`.
    generate_completions_from_executable(bin/"iriq", "completion", shells: [:bash, :zsh])
  end

  test do
    assert_match(/\A\d+\.\d+\.\d+\z/, shell_output("#{bin}/iriq --version").strip)
    assert_equal "https://foo.com/users/{user_id}",
                 shell_output("#{bin}/iriq -n https://foo.com/users/123").strip
    assert_match(/^complete -F _iriq iriq$/, shell_output("#{bin}/iriq completion bash"))
  end
end
