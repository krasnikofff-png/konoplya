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

## Как запустить игру
- **В редакторе:** открыть проект (Import → `project.godot`) и нажать **F5**.
- **Из командной строки:** в папке проекта `godot` (или полный путь к программе Godot).

### Управление (этап M0)
| Клавиша | Действие |
|---|---|
| WASD / стрелки | ходить активным героем |
| Tab | переключиться между Финном и Рико |
| Пробел | пауза / продолжить |
| 1 / 2 / 3 | скорость ×1 / ×2 / ×4 (или кнопки вверху) |
| F5 / F9 | быстрое сохранение / загрузка |

Сохранения лежат в папке данных Godot: `user://saves/quicksave.json`
(Windows: `%APPDATA%\Godot\app_userdata\Конопляная ферма\saves\`,
macOS: `~/Library/Application Support/Godot/app_userdata/Конопляная ферма/saves/`,
Linux: `~/.local/share/godot/app_userdata/Конопляная ферма/saves/`).

## Тесты
Без окна, из папки проекта:
```bash
godot --headless --import                      # один раз после скачивания проекта
godot --headless -s addons/gut/gut_cmdln.gd    # все тесты (настройки в .gutconfig.json)
```
или одной командой: `tools/run_tests.sh`. Тесты лежат в `tests/unit/` и `tests/integration/`.
В редакторе тесты можно запустить на нижней панели **GUT**.

## Где менять числа
Баланс хранится в файлах `.tres` (их можно открыть в редакторе Godot двойным щелчком или в любом текстовом редакторе):
- `data/config/time_config.tres` — длина суток (`real_seconds_per_day`, сейчас 360 с = 6 минут), скорости, начало утра/дня/вечера/ночи (минуты от полуночи), длина сезона;
- `data/config/new_game.tres` — старт новой игры: время, деньги, жар, братство, первый герой;
- `data/heroes/finn.tres`, `data/heroes/rico.tres` — цвет заглушки, скорость ходьбы, бонус своей сферы.

Тексты интерфейса — `localization/translations.csv` (колонки: ключ, русский, английский).

## Структура
```
core/         ядро: GameState, TimeSystem, SaveSystem, GameRng, команды, EventBus, Game
data/         описания данных (definitions/) и сами данные (.tres)
systems/      игровые системы (появятся с M1)
net/          сеть (с M2)
ui/           интерфейс и тема
world/        сцены мира: гараж, герои, предметы
dialogue/     диалоги (.dialogue), dialogue/events/ — сценки бесконечной игры
localization/ переводы
tests/        тесты GUT
tools/        служебные скрипты (установка Godot, запуск тестов)
docs/         ТЗ, сюжет, скриншоты
```
