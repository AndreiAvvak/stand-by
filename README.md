# Stand By — микро-сайт-заглушка

Статическая страница «Please Stand By» для будущих разделов экосистемы Symbol.

## Стек

- HTML + CSS (без сборки)
- SVG-тестовый паттерн (основной, векторный)
- PNG-версия (fallback + Open Graph)

## Локальный запуск

```bash
npm run dev
```

Откроется на http://localhost:4321

Или любой статический сервер:

```bash
npx serve public
```

## Деплой

Автодеплой на **GitHub Pages** при push в `main`.

- Репозиторий: https://github.com/AndreiAvvak/stand-by
- Сайт: https://andreiavvak.github.io/stand-by/

Workflow: `.github/workflows/pages.yml` — публикует содержимое `public/`.

### Reverse proxy (gosymbol.ru)

Технический домен проксируется через `TW_reverse_proxy` (77.233.223.195):

| Домен | Назначение |
|-------|-----------|
| `leaders-awards-st-sk-2026.gosymbol.ru` | HTTPS → GitHub Pages stand-by |
| `leaders.sporttech.sk.ru` | CNAME → gosymbol-домен (настраивает Сколково) |

Конфиг nginx: `nginx/leaders-standby-proxy.conf`

Цепочка:

```
leaders.sporttech.sk.ru  →  leaders-awards-st-sk-2026.gosymbol.ru  →  andreiavvak.github.io/stand-by/
     (Сколково DNS)              (TW_reverse_proxy)                        (GitHub Pages)
```

SSH: `ssh TW_reverse_proxy` (ключ `~/.ssh/timeweb_rproxy_ed25519`)

**SSL для `leaders.sporttech.sk.ru`:** сертификат Let's Encrypt нельзя выпустить, пока домен не резолвится (сейчас NXDOMAIN). На RP настроен cron каждые 2 часа — ` /opt/scripts/enable-leaders-sk-ssl.sh` автоматически выпустит cert и включит HTTPS-редirect, как только Сколково создаст запись:

```
leaders.sporttech.sk.ru  CNAME  leaders-awards-st-sk-2026.gosymbol.ru
# или  A  77.233.223.195
```

Чтобы ускорить: Сколково может создать DNS-запись заранее (до публичного анонса) — SSL подтянется автоматически в течение 2 часов.

### nginx / Docker (альтернатива)

```nginx
server {
    listen 80;
    server_name stand-by.example.ru;
    root /var/www/stand-by/public;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Docker

```bash
docker build -t stand-by .
docker run -p 8080:80 stand-by
```

## Файлы

| Файл | Назначение |
|------|-----------|
| `public/index.html` | Страница |
| `public/styles.css` | CRT-эффекты, вёрстка |
| `public/stand-by.svg` | Основное изображение (вектор) |
| `public/stand-by-pattern.png` | Растровая версия / OG-image |
| `public/favicon.svg` | Иконка вкладки |
