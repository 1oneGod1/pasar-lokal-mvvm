from __future__ import annotations

import re
from pathlib import Path

from pypdf import PdfReader

PDF_PATH = Path(r"c:\Users\Andi Purba\Downloads\Laporan Refleksi Usability Testing Aplikasi.pdf")


def main() -> None:
    if not PDF_PATH.exists():
        raise SystemExit(f"PDF not found: {PDF_PATH}")

    reader = PdfReader(str(PDF_PATH))
    pages_text: list[str] = []
    for page in reader.pages:
        pages_text.append(page.extract_text() or "")

    full = "\n".join(pages_text)
    print(f"pages={len(reader.pages)} extracted_chars={len(full)}")

    print("\n--- FULL TEXT ---")
    print(full)

    keywords = re.compile(
        r"(temuan|kendala|masalah|saran|perbaikan|rekomendasi|feedback|evaluasi|improve|update|revisi)",
        re.IGNORECASE,
    )

    candidates: list[str] = []
    for line in full.splitlines():
        s = line.strip()
        if not s:
            continue
        if keywords.search(s):
            candidates.append(s)

    print("\n--- CANDIDATE LINES (first 200) ---")
    for s in candidates[:200]:
        print("-", s)


if __name__ == "__main__":
    main()
