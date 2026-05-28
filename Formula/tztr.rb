class Tztr < Formula
  desc "Timezone Translator"
  homepage "https://github.com/dpep/tztr"
  url "https://github.com/dpep/tztr.git", branch: "main"
  version "0.1.0"
  license "MIT"

  depends_on "ruby"

  def install
    system Formula["ruby"].opt_bin/"gem", "build", "tztr.gemspec"
    built_gem = Pathname.glob("tztr-*.gem").first
    system Formula["ruby"].opt_bin/"gem", "install", built_gem,
           "--install-dir", libexec,
           "--bindir", libexec/"bin",
           "--no-document"
    (bin/"tztr").write_env_script libexec/"bin/tztr",
                                  GEM_HOME: libexec,
                                  GEM_PATH: libexec,
                                  PATH:     "#{Formula["ruby"].opt_bin}:$PATH"
  end

  test do
    assert_match(/\A\d+\.\d+\.\d+\z/, shell_output("#{bin}/tztr --version").strip)
    assert_equal "2026-04-03T05:00:00-07:00",
                 pipe_output("#{bin}/tztr -t America/Los_Angeles",
                             "2026-04-03T12:00:00Z\n").strip
  end
end
