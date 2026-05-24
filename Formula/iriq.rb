class Iriq < Formula
  desc "IRI extraction, normalization, and clustering"
  homepage "https://github.com/dpep/iriq"
  url "https://github.com/dpep/iriq.git", branch: "main"
  version "0.1.0"
  license "MIT"

  depends_on "ruby"

  def install
    system Formula["ruby"].opt_bin/"gem", "build", "iriq.gemspec"
    built_gem = Pathname.glob("iriq-*.gem").first
    system Formula["ruby"].opt_bin/"gem", "install", built_gem,
           "--install-dir", libexec,
           "--bindir", libexec/"bin",
           "--no-document"
    (bin/"iriq").write_env_script libexec/"bin/iriq",
                                  GEM_HOME: libexec,
                                  GEM_PATH: libexec,
                                  PATH: "#{Formula["ruby"].opt_bin}:$PATH"
  end

  test do
    assert_match(/\A\d+\.\d+\.\d+\z/, shell_output("#{bin}/iriq --version").strip)
    assert_equal "https://foo.com/users/{user_id}",
                 shell_output("#{bin}/iriq -n https://foo.com/users/123").strip
  end
end
