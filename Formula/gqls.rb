class Gqls < Formula
  desc "Fuzzy and semantic search over a GraphQL schema"
  homepage "https://github.com/dpep/gqls"
  url "https://github.com/dpep/gqls/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "61b755a417301c00d23971cf08912200c72926af9bbbe0ae16f9adc94fec4a75"
  license "MIT"

  depends_on "rust" => :build
  # Semantic search runs all-MiniLM-L6-v2 through ONNX Runtime, loaded
  # dynamically at runtime (the `semantic-dynamic` build) — no build-time
  # download or static linking, and it shares the keg with `ae`. The model
  # itself is fetched on first use into ~/.cache/huggingface/hub.
  depends_on "onnxruntime"

  def install
    system "cargo", "install", *std_cargo_args, "--features", "semantic-dynamic"

    generate_completions_from_executable(bin/"gqls", "--completions", shells: [:bash, :zsh, :fish])
  end

  test do
    assert_match(/^gqls \d+\.\d+\.\d+$/, shell_output("#{bin}/gqls --version").strip)
    assert_match "complete -F _gqls", shell_output("#{bin}/gqls --completions bash")

    (testpath/"schema.graphql").write <<~GRAPHQL
      type Query { user(id: ID!): User }
      type User { id: ID! name: String! }
    GRAPHQL
    # fuzzy: a root field floats to the top; a qualified Type.field query works
    assert_match "Query.user", shell_output("#{bin}/gqls user #{testpath}/schema.graphql")
    assert_match "User.name", shell_output("#{bin}/gqls User.name #{testpath}/schema.graphql")
  end
end
