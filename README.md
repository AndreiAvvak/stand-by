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
