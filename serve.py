#
# Simple Web Server to serve files from a directory
#
# EE May '24

from http.server import SimpleHTTPRequestHandler, HTTPServer
import os
import sys

PORT = 13000
WEBDIR = os.environ.get('WEBDIR', '.')


class CustomHandler(SimpleHTTPRequestHandler):

    def do_GET(self):
        if self.path == '/':
            self.path = '/screenshot.jpg'
            return SimpleHTTPRequestHandler.do_GET(self)
        else:
            self.send_error(404, "File not found")


if __name__ == '__main__':
    # Check if the filename is provided as a command-line argument
    if len(sys.argv) != 2:
        sys.exit(f'Usage: {sys.argv[0]} <filename>')

    # Get the filename to be served from command-line argument
    filename = sys.argv[1]
    if not os.path.exists(filename):
        sys.exit(f'Error: File "{filename}" not found')

    # Change directory to the specified WEBDIR
    os.chdir(WEBDIR)

    with HTTPServer(("", PORT), CustomHandler) as httpd:
        print(f"Serving {filename} on port {PORT}")
        httpd.serve_forever()
