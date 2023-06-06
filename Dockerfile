FROM ubuntu

WORKDIR /app

ADD https://github.com/purepoorx/caddy/releases/download/main/caddy-config-render caddy

ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared

COPY Caddyfile .

RUN chmod +x caddy cloudflared

CMD ./cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN} & ./caddy run --config Caddyfile --adapter caddyfile