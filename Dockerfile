FROM chenzhaoyu94/chatgpt-web:latest AS web

FROM ubuntu

RUN apt update && apt install -y curl wget unzip && curl -fsSL https://deb.nodesource.com/setup_19.x | bash - && apt install -y nodejs

WORKDIR /home/openai/app

ADD https://github.com/purepoorx/caddy/releases/download/main/caddy-config-base caddy

ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared

COPY Caddyfile .

RUN chmod +x caddy cloudflared

RUN npm install pnpm -g

COPY --from=web /app ./chatweb

EXPOSE 9999

CMD ./caddy run --config Caddyfile --adapter caddyfile & \
    ./cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN} & \
    pnpm -C chatweb run prod