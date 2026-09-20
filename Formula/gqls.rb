class Gqls < Formula
  desc "Fuzzy search over a GraphQL schema"
  homepage "https://github.com/dpep/gqls"
  url "https://github.com/dpep/gqls/archive/refs/tags/v0.26.1.tar.gz"
  sha256 "50226aec2516e148753b554a61274be45758b8f439af472e4222bd903b53abf2"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"gqls", "--completions")
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
    # wildcard: enumerates the type's fields, long form and trailing-dot shorthand
    assert_match "User.id", shell_output("#{bin}/gqls 'User.*' #{testpath}/schema.graphql")
    assert_match "User.id", shell_output("#{bin}/gqls User. #{testpath}/schema.graphql")
    # profile: reports phase timings on stderr
    assert_match "total", shell_output("#{bin}/gqls user #{testpath}/schema.graphql --profile 2>&1")
    # example: drafts a parameterized operation
    assert_match "query User($id: ID!)",
                 shell_output("#{bin}/gqls Query.user #{testpath}/schema.graphql -e")
  end
end
