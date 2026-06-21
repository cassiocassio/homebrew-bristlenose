class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/5c/8c/3f9faa669d767934de8c99fe24d90c0adb76ccaf0ab451f16777cf0fb3c1/bristlenose-0.15.18.tar.gz"
  sha256 "3c027165ad9e42cc2a11d5847d2b1fac14c741470063bbef2601009e73e27a73"
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
    # padding (av, cryptography). The [serve] extras pull in fastapi /
    # uvicorn / sqlalchemy so `bristlenose serve` works out of the box.
    system libexec/"bin/pip", "install", "bristlenose[serve]==#{version}"
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
