{ config, pkgs, lib, ... }:

# PHP, Composer, and the Laravel installer via php.new (Herd Lite).
# Static binaries live in ~/.config/herd-lite/bin — not Nix-managed, but
# the activation hook below bootstraps them on a fresh machine.
{
  home.sessionVariables = {
    # php.new keeps php.ini (CA cert config) next to its binaries
    PHP_INI_SCAN_DIR = "$HOME/.config/herd-lite/bin";
  };

  home.sessionPath = [
    "$HOME/.config/herd-lite/bin"
  ];

  home.activation.installHerdLite = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    HERD_LITE_BIN="$HOME/.config/herd-lite/bin"
    if [ ! -x "$HERD_LITE_BIN/php" ] && [ -z "''${DRY_RUN:-}" ]; then
      echo "php not found — installing PHP, Composer, and Laravel via php.new..."
      # Pre-add install dir to PATH so the script skips editing ~/.zshrc
      # (read-only Nix symlink); pipe through cat so it runs in non-tty mode.
      # The script itself needs curl and system tools on PATH.
      (
        export PATH="$HERD_LITE_BIN:${pkgs.curl}/bin:/usr/bin:/bin:$PATH"
        ${pkgs.curl}/bin/curl -fsSL "https://php.new/install/mac/8.5" \
          | ${pkgs.bash}/bin/bash 2>&1 | cat
      ) || true
      if [ -x "$HERD_LITE_BIN/php" ]; then
        echo "php.new install complete: $("$HERD_LITE_BIN/php" -v | head -n1)"
      else
        echo "warning: php.new install failed — run manually:" >&2
        echo "  /bin/bash -c \"\$(curl -fsSL https://php.new/install/mac/8.5)\"" >&2
      fi
    fi
  '';
}
