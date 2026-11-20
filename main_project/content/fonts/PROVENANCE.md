# Bundled font provenance

These exact, unmodified font files were copied from the Codex primary runtime's
Poppler `Library/share/fonts` distribution on 2026-11-20. The game uses committed
copies, not that installation or Windows system fonts. No native/runtime library,
toolchain selection or gameplay styling policy was changed.

| Resource ID | File | Embedded version | SHA-256 |
| --- | --- | --- | --- |
| recovery-sans | DejaVuSans.ttf | Version 2.37 | 7da195a74c55bef988d0d48f9508bd5d849425c1770dba5d7bfc6ce9ed848954 |
| sample-mono | Inconsolata-Regular.ttf | Version 3.000; ttfautohint (v1.8.3) | 127875d255d4c5973ca57267a43bb9d1c04397e6c7d236984a595b6cdcb12b7c |

`LICENSE.txt` is DejaVu's complete embedded name-table license (name ID 13):
Bitstream Vera and Arev notices, with DejaVu changes public domain. Font project:
[DejaVu](https://dejavu-fonts.github.io/).

`Inconsolata-LICENSE.txt` retains the embedded copyright/license/URL (name IDs
0/13/14). `Inconsolata-OFL.txt` contains the full SIL Open Font License 1.1 and
project copyright, downloaded from the
[project's Google Fonts license](https://github.com/google/fonts/blob/main/ofl/inconsolata/OFL.txt).
The asset is unmodified; there is no renamed derivative. Its synthetic fixture use
does not advertise a second supported language.

Godot imports the fonts as `.fontdata` resources with stable path remaps in the
Windows PCK. License `.txt` files are explicitly included. Runtime FontFile
creation reads original SFNT data through the resource, validates byte hashes and
disables system fallback. Committed import settings also disable it. No cache files or upstream classic
font assets are bundled. See [the runtime contract](../../scripts/data/LOCALE_FONTS.md).
