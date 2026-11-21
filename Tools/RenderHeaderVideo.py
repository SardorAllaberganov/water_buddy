#!/usr/bin/env python3
"""Renders the product page header's looping video (1.4.1).

    python3 Tools/RenderHeaderVideo.py <an empty frames folder> <out.mp4>

Tools/ProductPageHeader.html draws the header `t` seconds into its 8-second loop (`?t=`). This
draws every frame of the loop, 30 a second, with headless Chrome, four Chromes at once, each on a
throwaway profile of its own so none shares one or touches the owner's; then
Tools/EncodeHeaderVideo.swift encodes the 240 frames into the video. The loop's last frame comes
just before its first, so the video plays round without a seam.

The frames folder must be empty: this never deletes a frame it did not draw. Software rendering
(`--disable-gpu`), because on the GPU a busy page came out half drawn (Glazzy, 2026-11-20).

It lives in Tools/, outside every synchronized root group, and belongs to no build target (rule
15-project).
"""
import concurrent.futures
import pathlib
import subprocess
import sys
import tempfile
import threading

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
HERE = pathlib.Path(__file__).resolve().parent
PAGE = HERE / "ProductPageHeader.html"
LOOP, FPS, RENDERERS = 8, 30, 4


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: python3 Tools/RenderHeaderVideo.py <an empty frames folder> <out.mp4>")
    frames = pathlib.Path(sys.argv[1]).resolve()
    video = pathlib.Path(sys.argv[2]).resolve()
    frames.mkdir(parents=True, exist_ok=True)
    if any(frames.iterdir()):
        sys.exit(f"{frames}: not empty")
    profiles = tempfile.TemporaryDirectory()
    local = threading.local()

    def draw(index):
        if not hasattr(local, "profile"):
            local.profile = pathlib.Path(profiles.name) / str(threading.get_ident())
        subprocess.run([
            CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
            "--force-device-scale-factor=2", "--window-size=1920,823",
            "--allow-file-access-from-files", "--run-all-compositor-stages-before-draw",
            f"--user-data-dir={local.profile}", "--virtual-time-budget=3000",
            f"--screenshot={frames / f'{index:04d}.png'}",
            f"{PAGE.as_uri()}?t={index / FPS:.6f}",
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return index

    count = LOOP * FPS
    with concurrent.futures.ThreadPoolExecutor(max_workers=RENDERERS) as pool:
        for done, _ in enumerate(pool.map(draw, range(count)), start=1):
            if done % FPS == 0:
                print(f"  {done} of {count} frames")
    profiles.cleanup()
    subprocess.run(["swift", str(HERE / "EncodeHeaderVideo.swift"), str(frames), str(FPS), str(video)], check=True)


if __name__ == "__main__":
    main()
