# Posterum-IT site

Корпоративный сайт Posterum-IT: 1С, Windows/Linux серверы и собственная IT-инфраструктура.

## Стек
Next.js 15, React 19, TypeScript, PostgreSQL, Prisma, Docker.

## Запуск
1. Скопировать `.env.example` в `.env`.
2. Задать надёжный `POSTGRES_PASSWORD` и тот же пароль в `DATABASE_URL`.
3. Заполнить `MAX_BOT_TOKEN` и `MAX_CHAT_ID`.
4. Выполнить `docker compose up -d --build`.
5. Создать таблицы: `docker compose exec web npx prisma db push`.

Web слушает только `127.0.0.1:3000`; наружу его следует публиковать через nginx.

## Уже реализовано
Главная, страницы 1С/серверов/инфраструктуры/контактов, адаптивный дизайн, мобильный CTA, формы заявок, PostgreSQL-модель лидов и уведомления MAX.

## Следующий этап
Админ-панель лидов и настроек, авторизация администратора, управление статусами заявок, SEO/метаданные, production nginx и финальная проверка MAX API.
