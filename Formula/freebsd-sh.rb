class FreebsdSh < Formula
  desc "FreeBSD sh(1) ported to macOS — Bourne-lineage shell with faithful echo"
  homepage "https://github.com/dotike/freebsd-sh-macos"
  url "https://github.com/dotike/freebsd-sh-macos/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "8f4cf4b8cef056f9bbf78aa2c6c0de498f5683562719a3b5a075a8cbfe3b5e6f"
  license "BSD-2-Clause"

  def install
    system "make"
    bin.install "freebsd-sh"
  end

  test do
    # echo must be faithful: no escape interpretation
    assert_equal "hello\\nworld",
      shell_output("#{bin}/freebsd-sh -c 'echo \"hello\\nworld\"'").strip
  end
end
