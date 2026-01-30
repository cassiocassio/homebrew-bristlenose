class Bristlenose < Formula
  include Language::Python::Virtualenv

  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/69/f6/8a1ccdb581ac8a22e130c982b359629a38d89bad06124bee2cbdf293c9eb/bristlenose-0.1.0.tar.gz"
  sha256 "6172d7976fa9c1240d76027ec22f0f6077efa3bd2d0bd3bd3a49241d7326eed9"
  license "AGPL-3.0-only"

  depends_on "ffmpeg"
  depends_on "pkg-config" => :build
  depends_on "python@3.12"

  def install
    virtualenv_create(libexec, "python3.12")
    bin.install_symlink libexec/"bin/bristlenose"
  end

  def post_install
    system libexec/"bin/pip", "install", "--upgrade", "bristlenose==#{version}"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/bristlenose --help")
  end
end
