# Mark classes

## 1. Edit-based text (Unicode / rules)

Invisible or near-invisible characters, exotic spaces, bidi controls, tag
characters. **Removal:** Layer A, deterministic, verifiable (scripts in this
skill).

| Inspect kind | Examples |
| --- | --- |
| `zwj_family` | ZWSP, ZWNJ, ZWJ, WJ, BOM |
| `bidi` | LRE/RLO/LRI/… |
| `tag_chars` | U+E0001–U+E007F |
| `variation_selector` | VS1–VS256 |
| `space` | NBSP, em space, ideographic space |
| `confusable` | Cyrillic/fullwidth Latin (aggressive only) |

Emoji presentation glue is kept by default.

## 2. Generative / statistical text

Signal lives in **word choice**. Optional rewrite is best-effort; this Android
pack does not ship a Layer B rewriter. Do not claim human-written.

## 3. File provenance metadata (C2PA / EXIF / XMP)

Hard-bound manifests and EXIF/XMP: strip with ffmpeg/exiftool on a **named**
file (**media-edit**). Soft/pixel watermarks: out of scope.

## 4. Video overlays

`ffmpeg` `delogo` on a short named clip only. Feature-length files: tags only.
