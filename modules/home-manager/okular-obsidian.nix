# modules/okular-obsidian.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.okularObs;
  toStr = builtins.toString;
  renderYaml = meta: ''
    ---
    title: "${meta.title}"
    source: "[[${meta.pdfBase}.pdf]]"
    ---
  '';
in {
  options.programs.okularObs = {
    enable = lib.mkEnableOption "Okular + Obsidian Markdown export setup";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kdePackages.okular;
      description = "Okular package.";
    };

    pdfannotsPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pdfannots;
      description = "pdfannots for extracting annotations to Markdown.";
    };

    vaultPath = lib.mkOption {
      type = lib.types.path;
      example = "/home/you/Obsidian/ResearchVault";
      description = "Absolute path to your Obsidian vault.";
    };

    notesSubdir = lib.mkOption {
      type = lib.types.str;
      default = "papers";
      description = "Subdir inside the vault for exported Markdown notes.";
    };

    scriptPath = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/.local/bin/okular-to-md";
      description = "Helper script that converts annotations to Markdown.";
    };

    installExtras = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Also install ocrmypdf, tesseract, poppler-utils, ripgrep-all.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [cfg.package cfg.pdfannotsPackage]
      ++ lib.optionals cfg.installExtras [
        pkgs.ocrmypdf
        pkgs.tesseract
        pkgs.poppler-utils
        pkgs.ripgrep-all
      ];

    # Ensure vault/notes exist
    home.file."okular-vault-sentinel".target = "${toStr cfg.vaultPath}/.hm-ensure-exists";
    home.file."okular-vault-sentinel".text = "";
    home.file."okular-notes-sentinel".target = "${toStr cfg.vaultPath}/${cfg.notesSubdir}/.keep";
    home.file."okular-notes-sentinel".text = "";

    # Export helper: usage -> okular-to-md /abs/path/to/file.pdf
    home.file."okular-to-md".target = toStr cfg.scriptPath;
    home.file."okular-to-md".text = let
      notesDir = "${toStr cfg.vaultPath}/${cfg.notesSubdir}";
    in ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      if [ $# -lt 1 ]; then
        echo "Usage: ${cfg.scriptPath} <file.pdf>" >&2
        exit 2
      fi
      PDF="$1"
      if [ ! -f "$PDF" ]; then
        echo "File not found: $PDF" >&2
        exit 1
      fi
      dir="$(dirname "$PDF")"
      base="$(basename "$PDF")"
      stem="''${base%.*}"

      # Okular writes standard annotations directly into the PDF when you Save/Save As.
      # So we can run pdfannots on the same file.
      mkdir -p "${notesDir}"
      out_md="${notesDir}/''${stem}.md"

      "${cfg.pdfannotsPackage}/bin/pdfannots" "$PDF" -o "$out_md"

      # Prepend YAML if missing
      if [ ! -s "$out_md" ] || ! head -n1 "$out_md" | grep -q '^---$'; then
        tmp="$(mktemp)"
        {
          echo '---'
          echo "title: \"''${stem}\""
          echo "source: \"[[''${stem}.pdf]]\""
          echo '---'
          echo
          cat "$out_md"
        } > "$tmp"
        mv "$tmp" "$out_md"
      fi

      echo "Exported annotations → ${notesDir}/''${stem}.md"
    '';
    home.file."okular-to-md".executable = true;

    # Keep ~/.local/bin in PATH
    home.sessionPath = ["${config.home.homeDirectory}/.local/bin"];
  };
}
