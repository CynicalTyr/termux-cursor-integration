#!/usr/bin/env bash
# Non-destructive PATH check for yt-dlp + ffmpeg inside Ubuntu.
set -eu
command -v yt-dlp
yt-dlp --version
command -v ffmpeg
ffmpeg -version
