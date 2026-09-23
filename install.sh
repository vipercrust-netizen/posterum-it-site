#!/usr/bin/env bash
set -Eeuo pipefail
APP_NAME="posterum-it-site"; APP_DIR="/opt/${APP_NAME}"; APP_PORT="${APP_PORT:-3000}"; REPO="https://github.com/vipercrust-netizen/posterum-it-site.git"; CONF="/etc/${APP_NAME}.conf"
log(){ printf '\n\033[1;33m%s\033[0m\n' "$*"; }; fail(){ printf '\nОшибка: %s\n' "$*" >&2;exit 1; }; apt4(){ apt-get -o Acquire::ForceIPv4=true -o Acquire::Retries=3 "$@"; }
[[ "${EUID}" -eq 0 ]]||fail "запустите через sudo"
[[ -r /etc/os-release ]]||fail "не удалось определить ОС";. /etc/os-release;[[ "${ID:-}" == debian || "${ID_LIKE:-}" == *debian* ]]||fail "нужен Debian/Ubuntu"
DOMAIN="${DOMAIN:-}";LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL:-}"
if [[ -f "${CONF}" ]];then DOMAIN="${DOMAIN:-$(sed -n 's/^DOMAIN=//p' "${CONF}"|head -1)}";LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL:-$(sed -n 's/^LETSENCRYPT_EMAIL=//p' "${CONF}"|head -1)}";fi
if [[ -t 0 ]];then
 read -r -p "Домен [posterum-it.ru, пусто = по IP]: " x;DOMAIN="${x:-${DOMAIN:-posterum-it.ru}}"
 read -r -p "Email для Let's Encrypt [posterum-it@yandex.ru]: " x;LETSENCRYPT_EMAIL="${x:-${LETSENCRYPT_EMAIL:-posterum-it@yandex.ru}}"
 read -r -p "Логин администратора [admin]: " ADMIN_LOGIN;ADMIN_LOGIN="${ADMIN_LOGIN:-admin}"
 read -r -s -p "Пароль администратора (пусто = сгенерировать): " ADMIN_PASSWORD;printf '\n'
 read -r -p "MAX Chat ID (можно оставить пустым): " MAX_CHAT_ID
 read -r -s -p "MAX Bot Token (можно оставить пустым): " MAX_BOT_TOKEN;printf '\n'
else ADMIN_LOGIN="${ADMIN_LOGIN:-admin}";ADMIN_PASSWORD="${ADMIN_PASSWORD:-}";MAX_CHAT_ID="${MAX_CHAT_ID:-}";MAX_BOT_TOKEN="${MAX_BOT_TOKEN:-}";fi
printf 'DOMAIN=%s\nLETSENCRYPT_EMAIL=%s\n' "${DOMAIN}" "${LETSENCRYPT_EMAIL}" >"${CONF}";chmod 600 "${CONF}"
log "Установка системных компонентов";export DEBIAN_FRONTEND=noninteractive;apt4 update -qq;apt4 install -y -qq ca-certificates curl git nginx certbot docker.io docker-compose-plugin openssl || { apt4 install -y -qq ca-certificates curl git nginx certbot docker.io docker-compose openssl; }
systemctl enable --now docker
compose(){ if docker compose version >/dev/null 2>&1;then docker compose "$@";else docker-compose "$@";fi; }
if [[ ! -d "${APP_DIR}/.git" ]];then log "Загрузка Posterum-IT";git clone "${REPO}" "${APP_DIR}";else log "Обновление исходников";git -C "${APP_DIR}" pull --ff-only;fi
cd "${APP_DIR}"
if [[ ! -f .env ]];then
 DBPASS="$(openssl rand -hex 24)";SECRET="$(openssl rand -hex 48)";[[ -n "${ADMIN_PASSWORD}" ]]||ADMIN_PASSWORD="$(openssl rand -hex 9)"
 cat >.env <<EOF
DATABASE_URL="postgresql://posterum:${DBPASS}@db:5432/posterum"
POSTGRES_PASSWORD="${DBPASS}"
SESSION_SECRET="${SECRET}"
NEXT_PUBLIC_SITE_URL="${DOMAIN:+https://${DOMAIN}}"
MAX_BOT_TOKEN="${MAX_BOT_TOKEN}"
MAX_CHAT_ID="${MAX_CHAT_ID}"
ADMIN_LOGIN="${ADMIN_LOGIN}"
ADMIN_PASSWORD="${ADMIN_PASSWORD}"
EOF
 chmod 600 .env
else
 [[ -n "${MAX_BOT_TOKEN}" ]]&&sed -i "s|^MAX_BOT_TOKEN=.*|MAX_BOT_TOKEN=\"${MAX_BOT_TOKEN}\"|" .env
 [[ -n "${MAX_CHAT_ID}" ]]&&sed -i "s|^MAX_CHAT_ID=.*|MAX_CHAT_ID=\"${MAX_CHAT_ID}\"|" .env
fi
log "Сборка контейнеров";compose up -d --build --remove-orphans
install -m0755 "${APP_DIR}/scripts/deploy-posterum.sh" /usr/local/sbin/posterum-update
install -m0755 "${APP_DIR}/scripts/configure-https.sh" /usr/local/sbin/posterum-it-https
DOMAIN="${DOMAIN}" LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL}" /usr/local/sbin/posterum-it-https "${DOMAIN}" "${LETSENCRYPT_EMAIL}" "${APP_NAME}" "${APP_PORT}"
cat >/etc/systemd/system/posterum-it-certificate.service <<EOF
[Unit]
Description=Posterum-IT TLS certificate check
After=network-online.target nginx.service
[Service]
Type=oneshot
EnvironmentFile=${CONF}
ExecStart=/usr/local/sbin/posterum-it-https
EOF
cat >/etc/systemd/system/posterum-it-certificate.timer <<EOF
[Unit]
Description=Daily Posterum-IT TLS certificate check
[Timer]
OnCalendar=*-*-* 03:35:00
RandomizedDelaySec=30m
Persistent=true
[Install]
WantedBy=timers.target
EOF
systemctl daemon-reload;systemctl enable --now posterum-it-certificate.timer
for _ in $(seq 1 60);do curl -fsS "http://127.0.0.1:${APP_PORT}/" >/dev/null 2>&1&&break;sleep 2;done
curl -fsS "http://127.0.0.1:${APP_PORT}/" >/dev/null||{ compose logs --tail=100 web;fail "сайт не запустился"; }
IP="$(hostname -I|awk '{print $1}')";URL="http://${IP}";[[ -n "${DOMAIN}" && -s "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]]&&URL="https://${DOMAIN}"
printf '\n\033[1;32mУстановка завершена.\033[0m\nСайт: %s\nАдминка: %s/admin\n' "${URL}" "${URL}"
if [[ -n "${ADMIN_PASSWORD:-}" ]];then printf 'Первый вход: %s / %s\n' "${ADMIN_LOGIN}" "${ADMIN_PASSWORD}";fi
printf 'Обновление одной командой: sudo posterum-update\n'
