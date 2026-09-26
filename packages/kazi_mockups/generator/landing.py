"""Exports the mockups the landing page shows as WebP into kazi_landing/assets/screens/<lang>/."""
import pathlib
from PIL import Image

PACKAGE = pathlib.Path(__file__).parent.parent
TARGET = PACKAGE.parent / "kazi_landing/assets/screens"

LANDING_LANGS = {"pt-BR": "pt", "en-US": "en", "es-PY": "es"}
SCREENS = ["01_home", "02_services_list", "03_services_summary", "07_service_details"]

# The landing draws the screen at most 350px wide (280 × the 1.25 panel zoom); 720 covers it at 2x.
WIDTH = 720

def main():
    for locale, lang in LANDING_LANGS.items():
        (TARGET / lang).mkdir(parents=True, exist_ok=True)
        for slug in SCREENS:
            img = Image.open(PACKAGE / locale / f"{slug}.png").convert("RGB")
            img = img.resize((WIDTH, WIDTH * img.height // img.width), Image.LANCZOS)
            out = TARGET / lang / f"{slug}.webp"
            img.save(out, "WEBP", quality=88, method=6)
            print(out.relative_to(PACKAGE.parent), f"{out.stat().st_size // 1024} KB")

if __name__ == "__main__":
    main()
