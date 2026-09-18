# serve.py — servidor local de prueba de la web publicada (dotnet publish -c Release).
# En Windows, http.server toma los tipos MIME del registro y manda .js como text/plain;
# el Web Worker rechaza así el script (importScripts). Aquí se fuerzan los tipos correctos.
import http.server, os, sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8765

class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".js": "text/javascript", ".wasm": "application/wasm",
        ".json": "application/json", ".lisp": "text/plain; charset=utf-8",
        ".html": "text/html; charset=utf-8",
    }
    def guess_type(self, path):
        return self.extensions_map.get(os.path.splitext(path)[1].lower(), "application/octet-stream")

os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                      "HekatanLispWeb", "bin", "Release", "net10.0", "publish", "wwwroot"))
print(f"http://localhost:{PORT}/")
http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
