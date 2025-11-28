FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# ===== Install dependencies =====
RUN apt update && apt install -y \
    curl \
    screen \
    lsof \
    supervisor \
    ca-certificates \
    && apt clean

# ===== Download required binaries =====
# ech-server / opera / cloudflared
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl -L https://www.baipiao.eu.org/ech/ech-server-linux-amd64 -o ech-server; \
        curl -L https://github.com/Snawoot/opera-proxy/releases/latest/download/opera-proxy.linux-amd64 -o opera; \
        curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl -L https://www.baipiao.eu.org/ech/ech-server-linux-arm64 -o ech-server; \
        curl -L https://github.com/Snawoot/opera-proxy/releases/latest/download/opera-proxy.linux-arm64 -o opera; \
        curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o cloudflared; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && chmod +x ech-server opera cloudflared

# ===== Caddy =====
ADD https://github.com/purepoorx/caddy/releases/download/main/caddy-config-render caddy
COPY Caddyfile ./Caddyfile
RUN chmod +x caddy

# ===== geosite & geoip =====
ADD https://raw.githubusercontent.com/v2fly/domain-list-community/release/dlc.dat geosite.dat
ADD https://raw.githubusercontent.com/v2fly/geoip/release/geoip.dat geoip.dat

# ===== Add entrypoint =====
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# ===== Supervisor config =====
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 9999

ENTRYPOINT ["/app/entrypoint.sh"]
