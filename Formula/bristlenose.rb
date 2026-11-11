class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/02/fb/8b8f6979fee8df4e996931e9c9f401fb1671ab3023c571ed8df5ee71931e/bristlenose-0.46.0.tar.gz"
  sha256 "6cbb4c938e4f9ccaa6e3820ce30f7eed4d8f3bbcadcc2bf4538a7a2a26f960c1"
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
    # the Mac app, the Snap and the Fedora package. [any-llm] adds Mistral,
    # OpenRouter and other providers through mozilla-ai/any-llm (from 0.43.0;
    # it brings mistralai, OpenRouter and DeepSeek ride the openai SDK we
    # already install). A version without an extra installs with a pip
    # warning, not an error.
    system libexec/"bin/pip", "install", "bristlenose[voice,any-llm]==#{version}"
  end

  def caveats
    <<~EOS
      Bristlenose's analysis runs on the AI model you choose. Store a key
      for one provider (it is checked, then stored securely):
        bristlenose configure claude      # or chatgpt, gemini, azure
      For Mistral, OpenRouter, DeepSeek and others, through any-llm:
        bristlenose configure any-llm
      Or a model on this Mac, through Ollama:
        bristlenose configure local

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
