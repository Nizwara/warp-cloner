import os
from aiohttp import web
from loguru import logger
from config import config

async def handle_health(request: web.Request) -> web.Response:
    return web.json_response({"status": "ok", "app": "warp-cloner"})

async def handle_keys_raw(request: web.Request) -> web.Response:
    if os.path.exists(config.OUTPUT_FILE):
        with open(config.OUTPUT_FILE, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        return web.Response(text=content, content_type="text/plain")
    return web.Response(text="No keys generated yet.", status=404)

def html_escape(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

async def handle_dashboard(request: web.Request) -> web.Response:
    lines = []
    if os.path.exists(config.OUTPUT_FILE):
        with open(config.OUTPUT_FILE, "r", encoding="utf-8", errors="ignore") as f:
            lines = [line.strip() for line in f if line.strip()]

    total_keys = len(lines)
    recent_keys = lines[-50:]
    recent_keys_html = "\n".join(html_escape(line) for line in reversed(recent_keys)) if recent_keys else "No keys generated yet."

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warp Cloner Dashboard</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #111827; color: #f3f4f6; margin: 0; padding: 20px; }}
        .container {{ max-width: 900px; margin: 0 auto; background: #1f2937; padding: 24px; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.5); }}
        h1 {{ margin-top: 0; color: #60a5fa; }}
        .stats {{ display: flex; gap: 16px; margin-bottom: 20px; }}
        .card {{ background: #374151; padding: 16px; border-radius: 8px; flex: 1; }}
        .card .value {{ font-size: 28px; font-weight: bold; color: #10b981; }}
        .card .label {{ color: #9ca3af; font-size: 14px; }}
        .btn {{ display: inline-block; background: #2563eb; color: #fff; padding: 10px 18px; border-radius: 6px; text-decoration: none; font-weight: 500; margin-bottom: 20px; }}
        .btn:hover {{ background: #1d4ed8; }}
        pre {{ background: #111827; padding: 16px; border-radius: 8px; overflow-x: auto; color: #34d399; font-size: 14px; max-height: 400px; overflow-y: auto; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>⚡ Warp Cloner Dashboard</h1>
        <div class="stats">
            <div class="card">
                <div class="value">{total_keys}</div>
                <div class="label">Total Generated Keys</div>
            </div>
            <div class="card">
                <div class="value">ACTIVE</div>
                <div class="label">Status</div>
            </div>
        </div>
        <a href="/keys" class="btn">View Raw Output File</a>
        <h2>Recent Generated Keys (Latest 50)</h2>
        <pre>{recent_keys_html}</pre>
    </div>
</body>
</html>"""
    return web.Response(text=html, content_type="text/html")

async def start_web_server(host: str = "0.0.0.0", port: int = 8080) -> None:
    app = web.Application()
    app.router.add_get("/", handle_dashboard)
    app.router.add_get("/health", handle_health)
    app.router.add_get("/keys", handle_keys_raw)

    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, host, port)
    await site.start()
    logger.info(f"Web dashboard started at http://{host}:{port}")
