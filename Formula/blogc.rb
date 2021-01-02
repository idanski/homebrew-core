class Blogc < Formula
  desc "Blog compiler with template engine and markup language"
  homepage "https://blogc.rgm.io/"
  url "https://github.com/blogc/blogc/releases/download/v0.20.1/blogc-0.20.1.tar.xz"
  sha256 "d1289367362b7b11b438670fe703ff2c751e795393c06e1999d6b9a6e438fdd8"
  license "BSD-3-Clause"
  head "https://github.com/blogc/blogc.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "0261ed0fa3abb0db46377b07efbe9766498e45c7da54d0b8b4d80899fd08c100" => :big_sur
    sha256 "0771a236d34d67c6f1b4321acca5a22186c6b97747b203633f52f5c025221e3a" => :arm64_big_sur
    sha256 "6a317dc37a8c6fe8c0c607f0c5a94a2d3037b892896c7442e365eb337abb3a2f" => :catalina
    sha256 "26e69c263cf562fa5cbf411a943d6ff28537640472d09b39d47fb29e1d12ddbf" => :mojave
    sha256 "aed4dbb0098a80cee16f66523fe1bee118f5aba60746089a174880c34fbed0e2" => :high_sierra
  end

  def install
    system "./configure", "--disable-tests",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-git-receiver",
                          "--enable-make",
                          "--enable-runserver",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # Write config file that describes folder structure
    (testpath/"blogcfile").write <<~EOS
      [global]
      AUTHOR_NAME = Homebrew
      AUTHOR_EMAIL = brew@example.org
      SITE_TITLE = Homebrew
      SITE_TAGLINE = The Missing Package Manager for macOS (or Linux)
      BASE_DOMAIN = http://example.org

      [settings]
      locale = en_US.utf8

      [posts]
      post1
      post2
    EOS

    # Set up folder structure for a basic example site
    mkdir_p "content/post"
    mkdir_p "templates"
    (testpath/"content/post/post1.txt").write "----------\nfoo"
    (testpath/"content/post/post2.txt").write "----------\nbar"

    (testpath/"templates/main.tmpl").write <<~EOS
      <html>
      {{ SITE_TITLE }}
      {{ SITE_TAGLINE }}
      {% block listing %}{{ CONTENT }}{% endblock %}
      </html>
    EOS

    # Generate static files
    system bin/"blogc-make"

    # Run basic checks on generated files
    output = (testpath/"_build/index.html").read
    assert_match "Homebrew\nThe Missing Package Manager for macOS (or Linux)", output
    assert_match "<p>bar</p>\n<p>foo</p>", output
  end
end
