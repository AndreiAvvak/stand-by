#!/usr/bin/env bash
# Автовыпуск SSL для leaders.sporttech.sk.ru на TW_reverse_proxy.
# Запуск: вручную или cron (пока cert не получен).
set -euo pipefail

DOMAIN="leaders.sporttech.sk.ru"
TARGET_IP="77.233.223.195"
REDIRECT_TO="https://leaders-awards-st-sk-2026.gosymbol.ru"
CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"
SSL_SITE="/etc/nginx/sites-available/leaders-sporttech-sk-ssl"
SSL_ENABLED="/etc/nginx/sites-enabled/leaders-sporttech-sk-ssl"
LOG="/var/log/leaders-sk-ssl-setup.log"

log() { echo "[$(date -Iseconds)] $*" | tee -a "$LOG"; }

resolved_ip() {
  dig +short A "$DOMAIN" @1.1.1.1 | head -1
}

if [[ -f "$CERT_DIR/fullchain.pem" && -L "$SSL_ENABLED" ]]; then
  log "OK: cert and nginx SSL vhost already active for $DOMAIN"
  exit 0
fi

ip="$(resolved_ip || true)"
if [[ -z "$ip" ]]; then
  log "WAIT: $DOMAIN has no A/CNAME yet (NXDOMAIN or empty). Need DNS from Skolkovo."
  exit 0
fi

if [[ "$ip" != "$TARGET_IP" ]]; then
  log "WAIT: $DOMAIN resolves to $ip, expected $TARGET_IP"
  exit 0
fi

log "DNS OK ($ip). Requesting Let's Encrypt certificate..."

certbot certonly \
  --webroot -w /var/www/certbot \
  -d "$DOMAIN" \
  --non-interactive --agree-tos \
  -m admin@gosymbol.ru \
  --keep-until-expiring

cat > "$SSL_SITE" << NGINX
server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    ssl_certificate     ${CERT_DIR}/fullchain.pem;
    ssl_certificate_key ${CERT_DIR}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    return 301 ${REDIRECT_TO}\$request_uri;
}
NGINX

ln -sf "$SSL_SITE" "$SSL_ENABLED"
nginx -t
systemctl reload nginx

log "DONE: HTTPS redirect enabled for $DOMAIN → leaders-awards-st-sk-2026.gosymbol.ru"
