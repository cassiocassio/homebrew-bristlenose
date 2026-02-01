class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/9c/1f/f90ef6d69972e45eecc59cb4ecc1f1b9443ab43a42d203e1548d8fbd87e8/bristlenose-0.6.3.tar.gz"
  sha256 "635207be0049be6b3727cd03da5cc5723e4bd3cb8684f2360936cd0500d75043"
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
