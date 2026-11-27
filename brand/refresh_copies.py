"""Refreshes every project's copies of the Bayland Blue logos (see README.md).

Each game and the website keeps its own copies, made from the files here:

    python refresh_copies.py           # rewrite every copy that differs
    python refresh_copies.py --check   # only report; exits 1 if any is out of date

Projects are found beside this folder (D:/Dev/<project>); a missing one is
skipped. After refreshing a game, run `godot --headless --path . --import` in it
and commit the changed files there. Needs Pillow (pip install pillow).
"""

import io
import sys
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
DEV = HERE.parent
GAMES = ["GridUntangle", "Mineoku", "TraceEscape", "LeakyPipes", "Yardmaster", "AIAntennaTuner"]
SITE = "baylandblue.github.io"

LOGO_WITH_NAME = HERE / "bayland_blue_logo_with_name.png"
ICONS = HERE / "bayland_blue_icon_pngs"
CREAM = (0xFA, 0xF7, 0xF2, 255)


def _cropped_logo() -> Image.Image:
    """The full logo with the name, cropped to its visible area."""
    logo = Image.open(LOGO_WITH_NAME).convert("RGBA")
    return logo.crop(logo.getchannel("A").getbbox())


def _scaled(img: Image.Image, width: int) -> Image.Image:
    return img.resize((width, round(img.height * width / img.width)), Image.LANCZOS)


def boot_splash() -> Image.Image:
    """The logo 552 px wide on a cream disc 640 px across, centred on a
    transparent 1080x1920 canvas (Godot's launch splash)."""
    canvas = Image.new("RGBA", (1080, 1920), (0, 0, 0, 0))
    # The disc is drawn 4x and scaled down, for a smooth edge.
    big = Image.new("RGBA", (640 * 4, 640 * 4), (0, 0, 0, 0))
    ImageDraw.Draw(big).ellipse((0, 0, 640 * 4 - 1, 640 * 4 - 1), fill=CREAM)
    disc = big.resize((640, 640), Image.LANCZOS)
    canvas.alpha_composite(disc, ((1080 - 640) // 2, (1920 - 640) // 2))
    logo = _scaled(_cropped_logo(), 552)
    canvas.alpha_composite(logo, ((1080 - logo.width) // 2, (1920 - logo.height) // 2))
    return canvas


def site_logo() -> bytes:
    """The logo 640 px wide, as WebP quality 88 (the website's home page)."""
    out = io.BytesIO()
    _scaled(_cropped_logo(), 640).save(out, "WEBP", quality=88)
    return out.getvalue()


def _png(img: Image.Image) -> bytes:
    out = io.BytesIO()
    img.save(out, "PNG")
    return out.getvalue()


def copies() -> list[tuple[Path, bytes, bool]]:
    """Every copy: (path, wanted bytes, compare pixels rather than bytes)."""
    splash = _png(boot_splash())
    icon_144 = (ICONS / "bayland_blue_icon_144px.png").read_bytes()
    out = []
    for game in GAMES:
        brand = DEV / game / "assets" / "brand"
        if brand.is_dir():
            out.append((brand / "bayland_blue_icon.png", icon_144, False))
            out.append((brand / "boot_splash.png", splash, True))
    images = DEV / SITE / "images"
    if images.is_dir():
        out.append((images / "bayland_blue_logo.webp", site_logo(), False))
        for px in (48, 192):
            out.append((images / f"bayland_blue_icon_{px}.png",
                        (ICONS / f"bayland_blue_icon_{px}px.png").read_bytes(), False))
    return out


def _same(path: Path, wanted: bytes, by_pixels: bool) -> bool:
    if not path.exists():
        return False
    have = path.read_bytes()
    if have == wanted:
        return True
    if not by_pixels:
        return False
    # PNG encoders differ in compression; what matters is the image.
    a = Image.open(io.BytesIO(have)).convert("RGBA")
    b = Image.open(io.BytesIO(wanted)).convert("RGBA")
    return a.size == b.size and a.tobytes() == b.tobytes()


def main() -> int:
    check = "--check" in sys.argv[1:]
    stale = 0
    for path, wanted, by_pixels in copies():
        name = path.relative_to(DEV)
        if _same(path, wanted, by_pixels):
            print(f"  ok       {name}")
            continue
        stale += 1
        if check:
            print(f"  STALE    {name}")
        else:
            path.write_bytes(wanted)
            print(f"  updated  {name}")
    if check and stale:
        print(f"{stale} out of date: run python refresh_copies.py")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
