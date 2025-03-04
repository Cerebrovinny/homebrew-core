class Melange < Formula
  desc "Build APKs from source code"
  homepage "https://github.com/chainguard-dev/melange"
  url "https://github.com/chainguard-dev/melange/archive/refs/tags/v0.14.10.tar.gz"
  sha256 "ed1edc3f232645f4a7b0c7f25053ddd28fa5eed0a44b725b06177be1449bda8d"
  license "Apache-2.0"
  head "https://github.com/chainguard-dev/melange.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f0e9be3e237ba2dcf6d54535cb3944333e476edba047631d576a83a1fc3609ff"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f0e9be3e237ba2dcf6d54535cb3944333e476edba047631d576a83a1fc3609ff"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "f0e9be3e237ba2dcf6d54535cb3944333e476edba047631d576a83a1fc3609ff"
    sha256 cellar: :any_skip_relocation, sonoma:        "224a938695337f39130eaada1ac1c9e7e5b07ecc3855f544b03a4a3fd89c73d2"
    sha256 cellar: :any_skip_relocation, ventura:       "224a938695337f39130eaada1ac1c9e7e5b07ecc3855f544b03a4a3fd89c73d2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "cf9a3def4dc3a98eecfad4286c6c44e6d17ba4f4fcb70e4cb246904fcb62f74f"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X sigs.k8s.io/release-utils/version.gitVersion=#{version}
      -X sigs.k8s.io/release-utils/version.gitCommit=brew
      -X sigs.k8s.io/release-utils/version.gitTreeState=clean
      -X sigs.k8s.io/release-utils/version.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"melange", "completion")
  end

  test do
    (testpath/"test.yml").write <<~EOS
      package:
        name: hello
        version: 2.12
        epoch: 0
        description: "the GNU hello world program"
        copyright:
          - paths:
            - "*"
            attestation: |
              Copyright 1992, 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2005,
              2006, 2007, 2008, 2010, 2011, 2013, 2014, 2022 Free Software Foundation,
              Inc.
            license: GPL-3.0-or-later
        dependencies:
          runtime:

      environment:
        contents:
          repositories:
            - https://dl-cdn.alpinelinux.org/alpine/edge/main
          packages:
            - alpine-baselayout-data
            - busybox
            - build-base
            - scanelf
            - ssl_client
            - ca-certificates-bundle

      pipeline:
        - uses: fetch
          with:
            uri: https://ftp.gnu.org/gnu/hello/hello-${{package.version}}.tar.gz
            expected-sha256: cf04af86dc085268c5f4470fbae49b18afbc221b78096aab842d934a76bad0ab
        - uses: autoconf/configure
        - uses: autoconf/make
        - uses: autoconf/make-install
        - uses: strip
    EOS

    assert_equal "hello-2.12-r0", shell_output("#{bin}/melange package-version #{testpath}/test.yml")

    system bin/"melange", "keygen"
    assert_predicate testpath/"melange.rsa", :exist?

    assert_match version.to_s, shell_output(bin/"melange version 2>&1")
  end
end
