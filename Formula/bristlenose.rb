class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/9f/4a/78b3a209b4509d14c9ec3982961e0f9841b13c760094ed6a60a7adcf6b45/bristlenose-0.7.0.tar.gz"
  sha256 "80e47d2492d4c7da25aa98142cf1027ddce74268c7a49115b1e6d635d37ad8af"
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

    # Install man page from source tarball
    man1.install "man/bristlenose.1" if (buildpath/"man/bristlenose.1").exist?
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
