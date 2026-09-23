#!/usr/bin/env bash
set -Eeuo pipefail
APP_DIR="${APP_DIR:-/opt/posterum-it-site}"; APP_PORT="${APP_PORT:-3000}"
log(){ printf '\n\033[1;33m%s\033[0m\n' "$*"; }; fail(){ printf '\nОшибка: %s\n' "$*" >&2;exit 1; }
[[ "${EUID}" -eq 0 ]]||fail "запустите: sudo posterum-update"
[[ -d "${APP_DIR}/.git" && -f "${APP_DIR}/docker-compose.yml" ]]||fail "проект не найден в ${APP_DIR}"
REPO_USER="$(stat -c '%U' "${APP_DIR}")"
log "Получение обновлений...";runuser -u "${REPO_USER}" -- git -C "${APP_DIR}" pull --ff-only
compose(){ if docker compose version >/dev/null 2>&1;then docker compose "$@";else docker-compose "$@";fi; }
log "Сборка и запуск...";cd "${APP_DIR}";compose up -d --build --remove-orphans
log "Проверка сайта..."
for _ in $(seq 1 60);do if curl -fsS "http://127.0.0.1:${APP_PORT}/" >/dev/null 2>&1;then printf '\n\033[1;32mPosterum-IT успешно обновлён.\033[0m\n';exit 0;fi;sleep 2;done
compose logs --tail=100 web || true;fail "сайт не отвечает"
