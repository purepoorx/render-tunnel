#!/bin/bash
echo "=== Starting merged container ==="

# ===== Environment Variables =====
OPERA_PROXY=${OPERA_PROXY:-0}
OPERA_COUNTRY=${OPERA_COUNTRY:-AM}
ECH_TOKEN=${ECH_TOKEN:-""}
TUNNEL_TOKEN=${TUNNEL_TOKEN:-""}

if [ -z "$TUNNEL_TOKEN" ]; then
    echo "❌ ERROR: 必须提供 Cloudflare TUNNEL_TOKEN 环境变量"
    exit 1
fi

if [ "$OPERA_COUNTRY" != "AM" ] && [ "$OPERA_COUNTRY" != "AS" ] && [ "$OPERA_COUNTRY" != "EU" ]; then
    echo "❌ ERROR: OPERA_COUNTRY 必须是 AM, AS, 或 EU"
    exit 1
fi

# ===== 固定端口 =====
WS_PORT=9001
OPERA_PORT=9002

echo "ECH WS Port: $WS_PORT"
echo "Opera Proxy Port: $OPERA_PORT"

# ===== Generate Supervisor Config =====
cat <<EOF >/etc/supervisor/conf.d/services.conf
[program:opera]
command=/app/opera -country ${OPERA_COUNTRY} -socks-mode -bind-address 127.0.0.1:${OPERA_PORT}
autostart=$( [ "$OPERA_PROXY" = "1" ] && echo true || echo false )
autorestart=true

[program:ech]
command=/app/ech-server -l ws://127.0.0.1:${WS_PORT} $( [ -n "$ECH_TOKEN" ] && echo -token $ECH_TOKEN ) $( [ "$OPERA_PROXY" = "1" ] && echo "-f socks5://127.0.0.1:${OPERA_PORT}" )
autostart=true
autorestart=true

[program:cloudflared]
command=/app/cloudflared tunnel run --token ${TUNNEL_TOKEN}
autostart=true
autorestart=true

[program:caddy]
command=/app/caddy run --config /app/Caddyfile --adapter caddyfile
autostart=true
autorestart=true
EOF

echo "=== Starting Supervisor ==="
exec /usr/bin/supervisord -n
