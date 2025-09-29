# GTK youtube-transcribe

This document explains how to build, run, and troubleshoot the GTK front-end for Whisper-based transcriptions packaged under [`default.nix`](pkgs/youtube-transcribe/default.nix:1).

## Feature overview

- **Flexible input sources** &mdash; download audio directly from YouTube URLs or select local media files within the GTK UI.
- **Multi-language Whisper models** &mdash; runs English-optimized (`tiny.en`, `base.en`, `small.en`, `medium.en`) and general multilingual (`tiny`, `base`, `small`, `medium`, `large-v3`) models shipped via [`openai-whisper-cpp`](pkgs/youtube-transcribe/default.nix:1).
- **Caching-aware backend** &mdash; all model files and intermediate audio artifacts are cached under the XDG cache location (defaults to `~/.cache/youtube-transcribe`) to avoid repeated downloads.
- **Transcript export** &mdash; save outputs as plain text (`.txt`) or subtitle (`.srt`) files.

## Prerequisites

- Nix 2.13+ with flakes enabled (or `nix` command installed).
- Optional: Home Manager 24.05+ if you want to integrate the app via a per-user module.

## Building with Nix

1. Ensure you are at the repository root that contains [`flake.nix`](flake.nix:1).
2. Build the app:

   ```bash
   nix build .#youtube-transcribe
   ```

   - The resulting wrapper will be available at `./result/bin/youtube-transcribe`.
3. (Optional) Build within a clean environment using the `nix develop` shell:

   ```bash
   nix develop .#youtube-transcribe --command meson compile
   ```

   This ensures GTK4 dependencies match the derivation.

### Home Manager integration

If you use the Home Manager modules exported from [`flake.nix`](flake.nix:140), add the following to your configuration:

```nix
{ ... }:
{
  programs.home-manager.extraModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.youtube-transcribe ];
    })
  ];
}
```

Apply with:

```bash
home-manager switch --flake .#<hostname>
```

Replace `<hostname>` with the flake output that matches your machine.

## Running the GTK application

1. Launch the binary:

   ```bash
   ./result/bin/youtube-transcribe
   ```

2. Application workflow:
   - **Input selection** &mdash; choose *YouTube URL* or *Local file*. For YouTube, paste the full link; for local audio, use the file picker.
   - **Model selection** &mdash; pick a Whisper model (default: `tiny`). Multilingual models will be downloaded on first use.
   - **Language override** &mdash; the UI auto-detects language but allows manual override for English/German when using `.en` models.
   - **Start transcription** &mdash; pressing *Transcribe* schedules the job; progress is visible in the job list.
   - **Review and export** &mdash; once completed, open the transcript preview and export to `.txt` or `.srt`.

3. Cache locations:
   - Whisper models: `${XDG_CACHE_HOME:-$HOME/.cache}/youtube-transcribe/models`
   - Audio intermediates: `${XDG_CACHE_HOME:-$HOME/.cache}/youtube-transcribe/audio`
   - Logs: `${XDG_CACHE_HOME:-$HOME/.cache}/youtube-transcribe/logs`

4. Expected downloads:
   - Whisper model binaries can range from ~75&nbsp;MB (`tiny`) to ~2&nbsp;GB (`large-v3`).
   - YouTube audio is temporarily stored as `.wav` before transcription.

## Transcript handling

- Exported files default to `${XDG_DOCUMENTS_DIR:-$HOME/Documents}/youtube-transcribe`.
- You can drag-and-drop the transcript from the UI onto your file manager for quick copying.
- For scripting, invoke the CLI wrapper with `--output-file` to bypass the GUI (shares the same backend).

## Configuration and environment variables

| Variable | Description | Default |
| --- | --- | --- |
| `YOUTUBE_TRANSCRIBE_CACHE_DIR` | Override cache root. | `${XDG_CACHE_HOME:-$HOME/.cache}/youtube-transcribe` |
| `YOUTUBE_TRANSCRIBE_LOG_LEVEL` | Adjust logging verbosity (`info`, `debug`). | `info` |
| `WHISPER_CPP_THREADS` | Number of threads for transcription (passed to `openai-whisper-cpp`). | Auto-detected |
| `GTK_THEME` | Override GTK theme if rendering issues occur. | System default |

Example usage:

```bash
YOUTUBE_TRANSCRIBE_CACHE_DIR=/mnt/cache \
WHISPER_CPP_THREADS=8 \
./result/bin/youtube-transcribe
```

## Troubleshooting

| Symptom | Resolution |
| --- | --- |
| **Missing GTK runtime** | Run inside `nix develop` or ensure `gtk4`, `libadwaita`, and `gst_all_1.*` are available. |
| **Model download fails** | Verify network access and remove partial downloads: `rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/youtube-transcribe/models"/*`. Retry. |
| **“No space left on device”** | Whisper models are large. Set `YOUTUBE_TRANSCRIBE_CACHE_DIR` to a partition with free space. |
| **Transcription stuck at 0 %** | Increase `WHISPER_CPP_THREADS` or ensure CPU supports AVX; on unsupported hardware, switch to the `tiny` model. |
| **Audio decoding errors** | Install `ffmpeg` system-wide or run within the Nix shell to guarantee the correct version is used, as referenced in [`default.nix`](pkgs/youtube-transcribe/default.nix:3). |
| **Home Manager package missing** | Re-run `home-manager switch` after updating your flake; confirm `pkgs.youtube-transcribe` is included in `home.packages`. |

## Further reading

- Whisper project documentation: <https://github.com/openai/whisper>
- GTK4 application development: <https://docs.gtk.org/>
- Nix flakes guide: <https://nixos.wiki/wiki/Flakes>

If you encounter additional issues, open an issue referencing [`pkgs/youtube-transcribe`](pkgs/youtube-transcribe/default.nix:1) so maintainers can reproduce the environment.