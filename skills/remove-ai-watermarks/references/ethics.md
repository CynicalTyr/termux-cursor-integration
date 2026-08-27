# Intended use

This skill removes machine-readable provenance marks from content the operator
**owns or is authorized to process** on this phone.

## Appropriate

- Privacy: strip tool/device/AI provenance from your own files before sharing
- Hygiene: remove invisible Unicode that breaks diffs, search, or paste
- Cleaning your own drafts where policy allows unmarked local copies

## Not appropriate

- Academic fraud or misrepresenting AI assistance where disclosure is required
- Circumventing lawful transparency or platform disclosure rules
- Claiming cleaned content is “human-written”
- Pixel-domain unwatermark pipelines (GPU inpainters, untrusted pip)
- Crawling live websites to strip marks
- Walking all of DCIM / Pictures / Movies

A removed mark does **not** mean the content was never AI-assisted.

## Honesty in reports

Always separate:

1. **Verifiable** removals (Unicode counts, metadata actions)
2. **Best-effort** delogo interpolate (no gold undetection claim)
3. **Out of scope** (invisible pixel/audio SynthID, GPU inpainters)
