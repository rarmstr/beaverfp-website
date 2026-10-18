#!/usr/bin/env python3
"""Regenerate sitemap.xml with each page's real modification date.

lastmod is the date of the last commit that touched the page's file, or today
if the file has uncommitted changes. Run it after editing a page and before
committing, so the sitemap goes out in the same commit:

    python3 scripts/build-sitemap.py

Then, once the push is live, tell IndexNow: ./scripts/indexnow.sh
"""

import datetime
import pathlib
import subprocess

SITE = "https://beaverfp.com"
ROOT = pathlib.Path(__file__).resolve().parent.parent

# URL path -> file. A new page goes here too. 404.html is noindex, so it doesn't.
PAGES = [
    ("/", "index.html"),
    ("/about", "about.html"),
    ("/contact", "contact.html"),
    ("/privacy", "privacy.html"),
    ("/terms", "terms.html"),
]


def git(*args):
    return subprocess.run(
        ["git", "-C", str(ROOT), *args], capture_output=True, text=True, check=True
    ).stdout.strip()


def lastmod(file):
    if git("status", "--porcelain", "--", file):
        return datetime.date.today().isoformat()
    return git("log", "-1", "--format=%cs", "--", file)


def main():
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ]
    for path, file in PAGES:
        date = lastmod(file)
        lines += [
            "  <url>",
            f"    <loc>{SITE}{path}</loc>",
            f"    <lastmod>{date}</lastmod>",
            "  </url>",
        ]
        print(f"  {path:<10} {date}")
    lines.append("</urlset>")
    (ROOT / "sitemap.xml").write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
