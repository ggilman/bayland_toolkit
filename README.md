# Bayland Blue logos

The source files for Bayland Blue's brand. Copies used by the games and the website are made
from these. Change a logo here first, then refresh the copies listed below.

## Files

| File | Size | What it is |
|------|------|------------|
| `bayland_blue_logo_with_name.png` | 949×924 | The full logo: the round bay scene with "BAYLAND BLUE LLC" arched below it. For the website and anywhere the name should show. |
| `bayland_blue_logo with_arcs.png` | 949×979 | The full logo with thin gold arcs around it. |
| `bayland_blue_logo.png` | 760×788 | The round bay scene alone, without the name. |
| `bayland_blue_icon_pngs/bayland_blue_icon_<n>px.png` | 24 to 512 px | The simplified flat icon (sun, sea, shore and phone) in 24, 36, 48, 72, 96, 144, 192 and 512 px. For in-game use and favicons. |

All of them are RGBA PNGs with transparent corners. The lettering on the full logos is navy, so
on a dark background they need a light backing (the website puts them on a cream disc).

Colors from the icon: navy `#2b3d5c`, sea blue `#57718b`, sun gold `#dcac5c`, sand `#e6d6b6`,
sky cream `#f7f2ea`.

## Where the copies live

Nothing links to this folder; each project keeps its own copies, because Godot needs its files
inside the project.

| Copy | Made from |
|------|-----------|
| `Yardmaster`, `Mineoku`, `TraceEscape`: `assets/brand/bayland_blue_icon.png` | `bayland_blue_icon_144px.png`, copied as is. Imported with mipmaps on (`mipmaps/generate=true` in its `.import`) so it stays sharp when shown small. Used at the foot of each main menu (64 px) and on the credits/licenses screen (144 px). |
| `Yardmaster`, `Mineoku`, `TraceEscape`: `assets/brand/boot_splash.png` | `bayland_blue_logo_with_name.png` cropped to its visible area, scaled to 552 px wide (Lanczos), on a cream (`#faf7f2`) disc 640 px across, centered on a transparent 1080×1920 canvas. The disc keeps the navy lettering readable on the games' dark backgrounds. It's Godot's launch splash (`application/boot_splash/image`), drawn over each game's own background color. |
| `baylandblue.github.io`: `images/bayland_blue_logo.webp` | `bayland_blue_logo_with_name.png` cropped to its visible area, scaled to 640 px wide (Lanczos) and saved as WebP, quality 88. On the home page. |
| `baylandblue.github.io`: `images/bayland_blue_icon_48.png`, `images/bayland_blue_icon_192.png` | The 48 and 192 px icons, copied as is. The favicon and Apple touch icon, and the breadcrumb icon on each game page. |

`refresh_copies.py` makes all of them (Grid Untangle, Leaky Pipes and AIAntennaTuner too) from the files here,
following the recipes above. It needs Pillow:

    python refresh_copies.py           # rewrite every copy that differs
    python refresh_copies.py --check   # only report; exits 1 if any is out of date

On a Mac, use `python3` and `python3 -m pip install --user pillow`.

Run it after changing a logo, so no project is left with an old copy, then commit each project's
changes there.

After refreshing a game's copies, run `godot --headless --path . --import` in that project and
check the icon's `.import` still has mipmaps on.
