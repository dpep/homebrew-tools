class Gqls < Formula
  desc "Fuzzy and semantic search over a GraphQL schema"
  homepage "https://github.com/dpep/gqls"
  url "https://github.com/dpep/gqls/archive/refs/tags/v0.20.0.tar.gz"
  sha256 "61455e4d35a15f961de4ca868137e8a28b6024cfd9486d935cc09eb436266689"
  license "MIT"

  depends_on "rust" => :build
  # Semantic search runs all-MiniLM-L6-v2 through ONNX Runtime, loaded
  # dynamically at runtime (the `semantic-dynamic` build) — no build-time
  # download or static linking, and it shares the keg with `ae`. The model
  # itself is fetched on first use into ~/.cache/huggingface/hub.
  depends_on "onnxruntime"

  def install
    # `semantic` is a default feature (static-download ORT) — opt out of it here
    # and use `semantic-dynamic`, which dlopen's the onnxruntime keg instead.
    system "cargo", "install", *std_cargo_args, "--no-default-features", "--features", "semantic-dynamic"

    generate_completions_from_executable(bin/"gqls", "--completions", shells: [:bash, :zsh, :fish])
  end

  test do
    ENV["GQLS_NO_AUTOWARM"] = "1" # no background embed during the test
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
    assert_match "total", shell_output("#{bin}/gqls user #{testpath}/schema.graphql --profile --fuzzy 2>&1")
    # example: drafts a parameterized operation
    assert_match "query User($id: ID!)",
                 shell_output("#{bin}/gqls Query.user #{testpath}/schema.graphql -e")
  end
end
