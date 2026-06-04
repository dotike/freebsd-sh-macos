class Fsh < Formula
  desc "FreeBSD sh(1) ported to macOS — Bourne-lineage shell with faithful echo"
  homepage "https://github.com/dotike/freebsd-sh-macos"
  url "file:///tmp/fsh-0.2.0.tar.gz"
  sha256 "0cb98f7321605ea49e6a6f1dfa20e77eaa1a10474a1b97249582858f2d30acc6"
  license "BSD-2-Clause"

  depends_on "libedit"

  def install
    system "make", "LIBEDIT_PREFIX=#{Formula["libedit"].opt_prefix}",
                   "PREFIX=#{prefix}"
    system "make", "install", "LIBEDIT_PREFIX=#{Formula["libedit"].opt_prefix}",
                              "PREFIX=#{prefix}"
  end

  test do
    # echo must be faithful: no escape interpretation
    assert_equal "hello\\nworld",
      shell_output("#{bin}/fsh -c 'echo \"hello\\nworld\"'").strip
  end
end
