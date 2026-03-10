class Bristlenose < Formula
  desc "User-research transcription and quote extraction engine"
  homepage "https://github.com/cassiocassio/bristlenose"
  url "https://files.pythonhosted.org/packages/2b/f8/0b5037f203798518f1491cea281081e006af5502a026cbad584ebdc6d4e3/bristlenose-0.12.2.tar.gz"
  sha256 "b7b307c73792a17fe493cd5f5e5507809ff9408f06ae2ad0331599a05dda1def"
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

    # Install man page from source tarball
    man1.install "man/bristlenose.1" if (buildpath/"man/bristlenose.1").exist?
  end

  def post_install
    # pip install runs in post_install to skip Homebrew's dylib relinking
    # phase, which fails on pre-built wheels with short Mach-O header
    # padding (av, cryptography).
    system libexec/"bin/pip", "install", "bristlenose==#{version}"
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
