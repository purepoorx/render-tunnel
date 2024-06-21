FROM ubuntu

WORKDIR /app

ADD https://github.com/purepoorx/caddy/releases/download/main/caddy-config-render caddy

ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared

ADD https://raw.githubusercontent.com/v2fly/domain-list-community/release/dlc.dat geosite.dat

ADD https://raw.githubusercontent.com/v2fly/geoip/release/geoip.dat geoip.dat

COPY Caddyfile .

RUN chmod +x caddy cloudflared

CMD ./cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN} & ./caddy run --config Caddyfile --adapter caddyfile
