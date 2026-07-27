class Gqls < Formula
  desc "Fuzzy and semantic search over a GraphQL schema"
  homepage "https://github.com/dpep/gqls"
  url "https://github.com/dpep/gqls/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7ce31d8118cc63c2f2f3877a8c701a6f010ec6488f6bb0c59a373d12e23e8756"
  license "MIT"

  depends_on "rust" => :build

  def install
    # The default build ships fuzzy search, introspection (SDL/JSON/URL), and the
    # resolver jump. Semantic search (ONNX) is a heavier opt-in — build from
    # source with `cargo install gqls-cli --features semantic` if you want it.
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match(/^gqls \d+\.\d+\.\d+$/, shell_output("#{bin}/gqls --version").strip)

    (testpath/"schema.graphql").write <<~GRAPHQL
      type Query { user(id: ID!): User }
      type User { id: ID! name: String! }
    GRAPHQL
    # fuzzy: a root field floats to the top; a qualified Type.field query works
    assert_match "Query.user", shell_output("#{bin}/gqls user #{testpath}/schema.graphql")
    assert_match "User.name", shell_output("#{bin}/gqls User.name #{testpath}/schema.graphql")
  end
end
