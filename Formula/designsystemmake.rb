class Designsystemmake < Formula
  desc "Production-grade macOS Native Design System Token Studio & Exporter"
  homepage "https://github.com/mrKangHo/DesignSystemMake"
  url "https://github.com/mrKangHo/DesignSystemMake/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "cc7eb63140f2dee66bf308a1336e279f0f68f982f28fdb4d1d0def3405dfad09"
  license "MIT"

  depends_on xcode: ["15.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/DesignSystemMake" => "designsystemmake"
  end

  test do
    assert_predicate bin/"designsystemmake", :exist?
  end
end
