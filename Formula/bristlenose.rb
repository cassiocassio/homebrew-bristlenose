class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/ce/f7/172c9db52511b7249c70cdc79b962a80d2adc7ce1e1978a3509cb1293ba8/bristlenose-0.3.1.tar.gz"
  sha256 "38a4125d124c3d0c23cfcb2b9d3ac6440c98b30bd024eb3a9b8032e9ecfe9e4d"
  license "AGPL-3.0-only"

  depends_on "ffmpeg"
  depends_on "python@3.12"

  def install
    # Create a full venv (with pip) using Homebrew's Python
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", libexec

    # Install bristlenose and all deps into the venv
    system libexec/"bin/pip", "install", "bristlenose==#{version}"

    # Symlink the entry point into bin/
    bin.install_symlink libexec/"bin/bristlenose"
  end

  def caveats
    <<~EOS
      Bristlenose requires an Anthropic or OpenAI API key.
      Set one of:
        export BRISTLENOSE_ANTHROPIC_API_KEY=sk-ant-...
        export BRISTLENOSE_OPENAI_API_KEY=sk-...
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/bristlenose --help")
  end
end
