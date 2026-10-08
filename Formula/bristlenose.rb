class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/17/c2/57fc0d637d0133397432df54fca6c1b28386becbfe8bbca3a89321c0a554/bristlenose-0.36.0.tar.gz"
  sha256 "715589f87568e3e4ebbf0d6b3090652efba934c7ff26d3f8168725dae827d13f"
  license "AGPL-3.0-only"

  depends_on "ffmpeg"
  depends_on "python@3.12"

  def install
    # Create the venv during install so the Cellar directory exists.
    system Formula["python@3.12"].opt_bin/"python3.12", "-m", "venv", libexec

    # Write a wrapper script that delegates to the venv's bristlenose.
    # Must be a real file (not a symlink) during install so Homebrew's
    # link phase exposes it in /opt/homebrew/bin/ before post_install
    # runs pip.
    (bin/"bristlenose").write <<~SH
      #!/bin/bash
      exec "#{libexec}/bin/bristlenose" "$@"
    SH
    (bin/"bristlenose").chmod 0755

    # Install man page from the sdist source so it lands in the Cellar
    # before Homebrew's link phase runs. Installing it in post_install
    # bypasses link, so `man bristlenose` wouldn't resolve. Canonical
    # path is bristlenose/data/bristlenose.1; man/bristlenose.1 is a
    # symlink to it (works either way, but the canonical path is clearer).
    man1.install "bristlenose/data/bristlenose.1"
  end

  def post_install
    # pip install runs in post_install to skip Homebrew's dylib relinking
    # phase, which fails on pre-built wheels with short Mach-O header
    # padding (av, cryptography). The serve-mode packages (fastapi /
    # uvicorn / sqlalchemy) are core dependencies from the release after
    # 0.33.0, so no [serve] extra is needed here any more.
    # [voice] adds the voice pass to speaker identification (onnxruntime +
    # kaldi-native-fbank; the 40 MB model downloads on first use), matching
    # the Mac app, the Snap and the Fedora package. A version without the
    # extra installs with a pip warning, not an error.
    system libexec/"bin/pip", "install", "bristlenose[voice]==#{version}"
  end

  def caveats
    <<~EOS
      Bristlenose requires an Anthropic or OpenAI API key.
      Set one of:
        export BRISTLENOSE_ANTHROPIC_API_KEY=sk-ant-...
        export BRISTLENOSE_OPENAI_API_KEY=sk-...

      To keep Bristlenose current, trust this formula:
        brew trust --formula cassiocassio/bristlenose/bristlenose

      Homebrew 6.0 and later skip third-party taps during `brew upgrade`
      unless trusted. Without this, updates stop arriving silently.
    EOS
  end

  test do
    assert_match "Usage", shell_output("#{bin}/bristlenose --help")
  end
end
