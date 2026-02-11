class MochiSticky < Formula
  desc "The Sticky-Note Project Manager for Developers"
  homepage "https://github.com/mochizerodev/mochi-sticky"
  license "MIT"
  version "0.1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-darwin-arm64.tar.gz"
      sha256 "488997a1e63d16bf5a03a9b14ed19f547d5924ec6728c94653f7564f627eb7d9"
    else
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-darwin-amd64.tar.gz"
      sha256 "f582f3ac0a30f8bb2164b0b0b51c7d5efdb84b89a92597bdf186d49c753e5eee"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-linux-arm64.tar.gz"
      sha256 "8b33623376407dd3894fbc3d1695ec6b2e461378a4f628194f4231209fc29eb5"
    else
      url "https://github.com/mochizerodev/mochi-sticky/releases/download/v#{version}/mochi-sticky-linux-amd64.tar.gz"
      sha256 "b4361d95fc66d4c37827b90ed593f7fe2bbfa5a81565c9b5822734e29b1ce419"
    end
  end

  def install
    bin.install "mochi-sticky"
  end

  test do
    assert_match "mochi-sticky", shell_output("#{bin}/mochi-sticky --version")
  end
end
