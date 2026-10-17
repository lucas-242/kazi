# Kazi — app screen mockups

Seven screens × three locales, recreated from app screenshots.
Used for the store listings (Google Play and the App Store) and for the landing page ([kazi_landing](../kazi_landing)).

The same screens are rendered once per store, because no single size is accepted by both: Google Play rejects
anything taller than 2:1, and every App Store iPhone size is taller than that.

| Target | Folder | Size | Store slot |
|---|---|---|---|
| `play` | `<locale>/` | 1080 × 2160 (2:1) | Google Play phone screenshots; also the landing's source. No status bar, no Android navigation buttons |
| `iphone` | `app_store/iphone/<locale>/` | 1179 × 2556 | App Store "iPhone with Dynamic Island (medium)", the required set; the other iPhone sizes fall back to it. iOS status bar, Dynamic Island and home indicator, with the app inside the safe areas |

All are 24-bit PNG (no alpha), which both stores require. The layout is always drawn 360 px wide; a target only
changes the screen height, the scale and the phone UI around the app (`PLATFORMS` in `render.py`: the safe-area
insets and whether to draw the iOS status bar). The iPhone's extra height goes to its status bar and home
indicator, so both stores show the same content.

- `pt-BR` — Brazilian real (R$), dates dd/mm/yyyy
- `es-PY` — Paraguayan guaraní (Gs., no cents), "Setiembre", dates dd/mm/yyyy
- `en-US` — US dollar ($), dates mm/dd/yyyy

Screens: `01_home` · `02_services_list` · `03_services_summary` · `04_clients` · `05_settings` · `06_catalog` · `07_service_details`.

Every number comes from the same set of sample appointments (a barber who gets paid weekly, on Saturday), so they
all add up: month total, received and pending, daily and weekly bars, earnings per service and per-client totals.
Names, e-mails and profiles are fictional.

## Regenerating

The script lives in `generator/`. It needs Python with Playwright and Pillow (`pip install playwright pillow`,
then `playwright install chromium`) and, in that same folder, `npm i @fontsource/archivo lucide-static`.

Copy, prices and names live in `data.py`; the layout and the `TARGETS` sizes in `render.py`. Run `python3 render.py`
from inside `generator/` to render every target and locale; narrow it with a locale (`python3 render.py pt-BR`)
and/or a target (`--target=iphone`). PNGs are written to `generator/out/<target>/<locale>/` (the intermediate HTML
to `generator/out/html/`); copy the ones you keep into the folders in the table above.

`python3 landing.py` then exports the screens the landing page shows (`01`, `02`, `03`, `07`) as 720px-wide
WebP into `kazi_landing/assets/screens/<pt|en|es>/`. It reads the PNGs in `<locale>/`, so copy first, and it
needs Pillow. The landing's alt texts quote the sample numbers; update them if `data.py` changes.
