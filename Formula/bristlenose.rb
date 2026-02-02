class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/4c/1d/2a7dc60114739bbb211fd700b54266d4cee670647c9c73b95f88c24eadfe/bristlenose-0.6.6.tar.gz"
  sha256 "e3bf21c4d4fab10d26ccd094b667b43b34e28281c5cd70c6574575b4981a2123"
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
