#!/usr/bin/env python3
"""Local preview server for the Beaver FP website.

Serves the site on http://localhost:8000 and resolves clean URLs the same way
GitHub Pages does, so links like /privacy and /terms work locally exactly as
they do in production.

Usage:
    python3 serve.py            # serve on port 8000
    python3 serve.py 9000       # serve on a custom port
"""

import http.server
import os
import socketserver
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
ROOT = os.path.dirname(os.path.abspath(__file__))


class CleanURLHandler(http.server.SimpleHTTPRequestHandler):
    """Maps extensionless paths (/privacy) to their .html file, like GitHub Pages."""

    def translate_path(self, path):
        local = super().translate_path(path)
        # If the request has no extension and no such file/dir exists,
        # try the .html variant (e.g. /privacy -> privacy.html).
        if not os.path.exists(local) and not os.path.splitext(local)[1]:
            if os.path.exists(local + ".html"):
                return local + ".html"
        return local

    def end_headers(self):
        # Disable caching so edits show up immediately on refresh.
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()


def main():
    os.chdir(ROOT)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), CleanURLHandler) as httpd:
        print(f"Beaver FP site → http://localhost:{PORT}  (Ctrl-C to stop)")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nStopped.")


if __name__ == "__main__":
    main()
