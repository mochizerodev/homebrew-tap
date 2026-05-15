class MochiSticky < Formula
  desc "The Sticky-Note Project Manager for Developers"
  homepage "https://github.com/mochizerodev/mochi-sticky"
  license "MIT"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-darwin-arm64.tar.gz"
      sha256 "7cb4be4d6547b735dd18a333fe10d543a177868a9c22bb1f696df3bac66a6a72"
    else
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-darwin-amd64.tar.gz"
      sha256 "e80923eb00badf6bcf7f9483b4be294e0a488ad7ca48f4997fd2b07e9b2a98f8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-linux-arm64.tar.gz"
      sha256 "34d9a55640b275f584a4f1d5662aced1a6deebff40d3217f8615bcc11c4e3c17"
    else
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-linux-amd64.tar.gz"
      sha256 "bed9cf788c9e9de2de5bf5ecac6e099d2c0bddb56d6650883b3b0306709eb122"
    end
  end

  def install
    bin.install "mochi-sticky"
  end

  test do
    assert_match "mochi-sticky", shell_output("#{bin}/mochi-sticky --version")
  end
end
