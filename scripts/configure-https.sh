#!/usr/bin/env bash
set -Eeuo pipefail
DOMAIN="${DOMAIN:-${1:-}}"; EMAIL="${LETSENCRYPT_EMAIL:-${2:-}}"; APP_NAME="${APP_NAME:-${3:-posterum-it-site}}"; APP_PORT="${APP_PORT:-${4:-3000}}"
WEBROOT="/var/www/certbot"; AV="/etc/nginx/sites-available/${APP_NAME}"; EN="/etc/nginx/sites-enabled/${APP_NAME}"; CERT="/etc/letsencrypt/live/${DOMAIN}"
log(){ printf '\n[HTTPS] %s\n' "$*"; }
proxy(){ cat <<EOF
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
EOF
}
http(){ cat >"${AV}" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    location ^~ /.well-known/acme-challenge/ { root ${WEBROOT}; default_type text/plain; }
    location / {
$(proxy)
    }
}
EOF
}
https(){ cat >"${AV}" <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    location / {
$(proxy)
    }
}
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};
    location ^~ /.well-known/acme-challenge/ { root ${WEBROOT}; default_type text/plain; }
    location / { return 301 https://${DOMAIN}\$request_uri; }
}
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN} www.${DOMAIN};
    ssl_certificate ${CERT}/fullchain.pem;
    ssl_certificate_key ${CERT}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    location / {
$(proxy)
    }
}
EOF
}
install -d -m0755 "${WEBROOT}"
if [[ -z "${DOMAIN}" ]];then http;ln -sfn "${AV}" "${EN}";rm -f /etc/nginx/sites-enabled/default;nginx -t;systemctl enable --now nginx;systemctl reload nginx;log "Работа по HTTP/IP";exit 0;fi
[[ "${DOMAIN}" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ && "${DOMAIN}" == *.* ]] || { echo "Некорректный домен";exit 1; }
exists=false;[[ -s "${CERT}/fullchain.pem" && -s "${CERT}/privkey.pem" ]]&&exists=true
if [[ "${exists}" == false ]];then
 http;ln -sfn "${AV}" "${EN}";rm -f /etc/nginx/sites-enabled/default;nginx -t;systemctl enable --now nginx;systemctl reload nginx
 args=(--register-unsafely-without-email);[[ -n "${EMAIL}" ]]&&args=(-m "${EMAIL}")
 certbot certonly --webroot -w "${WEBROOT}" --non-interactive --agree-tos "${args[@]}" --cert-name "${DOMAIN}" -d "${DOMAIN}" -d "www.${DOMAIN}" || { log "SSL пока не получен; оставлен HTTP";exit 0; }
elif ! openssl x509 -checkend 2592000 -noout -in "${CERT}/fullchain.pem" >/dev/null 2>&1;then
 args=(--register-unsafely-without-email);[[ -n "${EMAIL}" ]]&&args=(-m "${EMAIL}")
 certbot certonly --webroot -w "${WEBROOT}" --non-interactive --agree-tos "${args[@]}" --cert-name "${DOMAIN}" --force-renewal -d "${DOMAIN}" -d "www.${DOMAIN}" || true
fi
if [[ -s "${CERT}/fullchain.pem" ]]&&openssl x509 -checkend 0 -noout -in "${CERT}/fullchain.pem" >/dev/null 2>&1;then https;else http;fi
ln -sfn "${AV}" "${EN}";rm -f /etc/nginx/sites-enabled/default;nginx -t;systemctl enable --now nginx;systemctl reload nginx
