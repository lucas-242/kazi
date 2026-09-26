# Kazi — app screen mockups

Six screens × three locales, recreated from app screenshots, with no status bar and no Android navigation buttons.
Used for the store listings (Google Play) and for the landing page ([kazi_landing](../kazi_landing)).

- Format: 24-bit PNG (no alpha), 1080 × 2160 px, 2:1 aspect ratio — within Google Play's screenshot limits.
- `pt-BR` — Brazilian real (R$), dates dd/mm/yyyy
- `es-PY` — Paraguayan guaraní (Gs., no cents), "Setiembre", dates dd/mm/yyyy
- `en-US` — US dollar ($), dates mm/dd/yyyy

Screens: `01_home` · `02_services_list` · `03_services_summary` · `04_clients` · `05_settings` · `06_catalog` · `07_service_details`.

Every number comes from the same set of sample appointments (a barber who gets paid weekly, on Saturday), so they
all add up: month total, received and pending, daily and weekly bars, earnings per service and per-client totals.
Names, e-mails and profiles are fictional.

## Regenerating

The script lives in `generator/`. It needs Python with Playwright and, in that same folder,
`npm i @fontsource/archivo lucide-static`.

Copy, prices and names live in `data.py`; the layout in `render.py`. Run `python3 render.py` (or
`python3 render.py pt-BR` for a single locale) from inside `generator/`. PNGs are written to
`generator/out/<locale>/` (the intermediate HTML to `generator/out/html/`); copy the ones you keep into the
`<locale>/` folders here.

`python3 landing.py` then exports the screens the landing page shows (`01`, `02`, `03`, `07`) as 720px-wide
WebP into `kazi_landing/assets/screens/<pt|en|es>/`. It reads the PNGs in `<locale>/`, so copy first, and it
needs Pillow. The landing's alt texts quote the sample numbers; update them if `data.py` changes.
