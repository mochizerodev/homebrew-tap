class MochiSticky < Formula
  desc "The Sticky-Note Project Manager for Developers"
  homepage "https://github.com/mochizerodev/mochi-sticky"
  license "MIT"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-darwin-arm64.tar.gz"
      sha256 "REPLACE_WITH_DARWIN_ARM64_SHA256"
    else
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-darwin-amd64.tar.gz"
      sha256 "REPLACE_WITH_DARWIN_AMD64_SHA256"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-linux-arm64.tar.gz"
      sha256 "REPLACE_WITH_LINUX_ARM64_SHA256"
    else
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-linux-amd64.tar.gz"
      sha256 "REPLACE_WITH_LINUX_AMD64_SHA256"
    end
  end

  def install
    bin.install "mochi-sticky"
  end

  test do
    assert_match "mochi-sticky", shell_output("#{bin}/mochi-sticky --version")
  end
end

