class Fsh < Formula
  desc "FreeBSD sh(1) ported to macOS — Bourne-lineage shell with faithful echo"
  homepage "https://github.com/dotike/freebsd-sh-macos"
  url "file:///tmp/fsh-0.2.0.tar.gz"
  sha256 "96e33eed808a07bb076fe4c7c19257d27e043ce37b348413bb3932929f8ddefe"
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
