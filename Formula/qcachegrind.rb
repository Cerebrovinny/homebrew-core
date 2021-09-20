class Qcachegrind < Formula
  desc "Visualize data generated by Cachegrind and Calltree"
  homepage "https://kcachegrind.github.io/"
  url "https://download.kde.org/stable/release-service/21.08.1/src/kcachegrind-21.08.1.tar.xz"
  sha256 "fb8bbbba0178f33c8a4bdace2fdfe747036822b5fa9013b5905a1de5198def27"
  license "GPL-2.0-or-later"

  # We don't match versions like 19.07.80 or 19.07.90 where the patch number
  # is 80+ (beta) or 90+ (RC), as these aren't stable releases.
  livecheck do
    url "https://download.kde.org/stable/release-service/"
    regex(%r{href=.*?v?(\d+\.\d+\.(?:(?![89]\d)\d+)(?:\.\d+)*)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "e463fbfe5a4ef00611f34c0a0e049f96df312a1eddc779a0834741f23da1efdb"
    sha256 cellar: :any,                 big_sur:       "c97be1624d3b85d6d2b7b947d28571459026d0aa222224e438d4b6a730d2016b"
    sha256 cellar: :any,                 catalina:      "8988bd786e8d2d4c0ac589fd747ccb388ae343ddb262742c2231f94c88c39943"
    sha256 cellar: :any,                 mojave:        "996472038ca71170dd567f04a37fc44d1c08dfda365f3ea986e057dda1d4c00c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "459804a72f566b4ae5ed724416c741dc301af09029bda5a5e4647c7ee6092327"
  end

  depends_on "graphviz"
  depends_on "qt@5"

  on_linux do
    depends_on "gcc"
  end

  fails_with gcc: "5"

  def install
    args = ["-config", "release", "-spec"]
    os = OS.mac? ? "macx" : OS.kernel_name.downcase
    compiler = ENV.compiler.to_s.start_with?("gcc") ? "g++" : ENV.compiler
    arch = Hardware::CPU.intel? ? "" : "-#{Hardware::CPU.arch}"
    args << "#{os}-#{compiler}#{arch}"

    system Formula["qt@5"].opt_bin/"qmake", *args
    system "make"

    if OS.mac?
      prefix.install "qcachegrind/qcachegrind.app"
      bin.install_symlink prefix/"qcachegrind.app/Contents/MacOS/qcachegrind"
    else
      bin.install "qcachegrind/qcachegrind"
    end
  end
end
