#!/usr/bin/env ruby

require "fileutils"
require "json"
require "net/http"
require "uri"

UPSTREAM_REPO = ENV.fetch("MOCHI_STICKY_UPSTREAM", "mochizerodev/mochi-sticky")
FORMULA_PATH = ENV.fetch("MOCHI_STICKY_FORMULA_PATH", File.join(__dir__, "..", "Formula", "mochi-sticky.rb"))

ASSET_ARCHIVES = {
  "darwin_arm64" => "mochi-sticky-darwin-arm64.tar.gz",
  "darwin_amd64" => "mochi-sticky-darwin-amd64.tar.gz",
  "linux_arm64" => "mochi-sticky-linux-arm64.tar.gz",
  "linux_amd64" => "mochi-sticky-linux-amd64.tar.gz",
}.freeze

def http_get(url, token: nil, accept: nil, max_redirects: 5)
  uri = URI(url)
  req = Net::HTTP::Get.new(uri)
  req["Accept"] = accept if accept
  req["User-Agent"] = "homebrew-tap-updater"
  req["Authorization"] = "Bearer #{token}" if token && !token.empty?

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    res = http.request(req)

    if res.is_a?(Net::HTTPRedirection)
      raise "Too many redirects for #{url}" if max_redirects <= 0
      location = res["location"]
      raise "Redirect without location for #{url}" if location.to_s.empty?
      return http_get(location, token: nil, accept: accept, max_redirects: max_redirects - 1)
    end

    raise "GET #{url} failed: #{res.code} #{res.message}\n#{res.body}" unless res.is_a?(Net::HTTPSuccess)
    res.body
  end
end

def http_get_json(url, token: nil)
  JSON.parse(http_get(url, token: token, accept: "application/vnd.github+json"))
end

def http_get_text(url, token: nil, accept: nil)
  http_get(url, token: token, accept: accept)
end

def parse_sha256(text)
  # Accept either "<sha>" or "<sha>  <filename>"
  sha = text.to_s.strip.split(/\s+/).first
  unless sha&.match?(/\A[0-9a-f]{64}\z/i)
    raise "Unexpected sha256 content: #{text.inspect}"
  end
  sha.downcase
end

token = ENV["GITHUB_TOKEN"]

release = http_get_json("https://api.github.com/repos/#{UPSTREAM_REPO}/releases/latest", token: token)
tag = release.fetch("tag_name")
version = tag.sub(/\Av/i, "")

assets = release.fetch("assets")

checksums = {}
ASSET_ARCHIVES.each do |key, archive|
  checksum_asset_name = "#{archive}.sha256"
  asset = assets.find { |a| a["name"] == checksum_asset_name }
  raise "Missing release asset: #{checksum_asset_name}" unless asset

  checksum_text = http_get_text(asset.fetch("url"), token: token, accept: "application/octet-stream")
  checksums[key] = parse_sha256(checksum_text)
end

formula = <<~RUBY
  class MochiSticky < Formula
    desc "The Sticky-Note Project Manager for Developers"
    homepage "https://github.com/#{UPSTREAM_REPO}"
    license "MIT"
    version "#{version}"

    on_macos do
      if Hardware::CPU.arm?
        url "https://github.com/#{UPSTREAM_REPO}/releases/download/v\#{version}/mochi-sticky-darwin-arm64.tar.gz"
        sha256 "#{checksums.fetch("darwin_arm64")}"
      else
        url "https://github.com/#{UPSTREAM_REPO}/releases/download/v\#{version}/mochi-sticky-darwin-amd64.tar.gz"
        sha256 "#{checksums.fetch("darwin_amd64")}"
      end
    end

    on_linux do
      if Hardware::CPU.arm?
        url "https://github.com/#{UPSTREAM_REPO}/releases/download/v\#{version}/mochi-sticky-linux-arm64.tar.gz"
        sha256 "#{checksums.fetch("linux_arm64")}"
      else
        url "https://github.com/#{UPSTREAM_REPO}/releases/download/v\#{version}/mochi-sticky-linux-amd64.tar.gz"
        sha256 "#{checksums.fetch("linux_amd64")}"
      end
    end

    def install
      bin.install "mochi-sticky"
    end

    test do
      assert_match "mochi-sticky", shell_output("\#{bin}/mochi-sticky --version")
    end
  end
RUBY

FileUtils.mkdir_p(File.dirname(FORMULA_PATH))
File.write(FORMULA_PATH, formula)
puts "Wrote #{FORMULA_PATH} for #{UPSTREAM_REPO}@#{tag}"
