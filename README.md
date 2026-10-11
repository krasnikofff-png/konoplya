# Конопляная ферма (konoplya)

Тайкун / менеджмент-симулятор с сюжетной кампанией и кооперативом на Godot 4.

- Техническое задание: [`docs/GAME_SPEC.md`](docs/GAME_SPEC.md)
- Сюжет и этапы: [`docs/STORY.md`](docs/STORY.md)
- Прогресс: [`PROGRESS.md`](PROGRESS.md)
- Решения: [`DECISIONS.md`](DECISIONS.md)

## Движок

**Godot 4.7.2 stable** (стандартная версия, не .NET).

### Путь к бинарнику
- Облачное окружение разработки: `/usr/local/bin/godot` → `/opt/godot/Godot_v4.7.2-stable_linux.x86_64`.
  Переустановка в новой сессии:
  ```bash
  mkdir -p /opt/godot && cd /opt/godot \
    && curl -sSL -o g.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip \
    && unzip -oq g.zip && rm g.zip \
    && ln -sf /opt/godot/Godot_v4.7.2-stable_linux.x86_64 /usr/local/bin/godot
  ```
- Компьютер автора: см. ниже.

### Установка на свой компьютер
1. Откройте https://godotengine.org/download и выберите свою систему.
2. Скачайте **Godot Engine** (обычную версию, **не** «.NET»), версию 4.7.2.
3. Windows: распакуйте zip, например в `C:\Godot\`, запускайте `Godot_v4.7.2-stable_win64.exe`.
   macOS: откройте dmg и перетащите Godot в «Программы».
   Linux: распакуйте zip и сделайте файл исполняемым (`chmod +x`).
4. Скачайте проект: на GitHub кнопка **Code → Download ZIP** (или `git clone`), распакуйте.
5. В Godot: **Import** → выберите файл `project.godot` из папки проекта → **Import & Edit** → **F5** (запуск).

Команды запуска и тестов появятся здесь по итогам M0.
