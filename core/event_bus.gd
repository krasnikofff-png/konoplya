extends Node
## Глобальные сигналы игры (автозагрузка EventBus).
## Системы симуляции сюда не пишут напрямую — их сигналы ретранслирует Game.

## Прошла одна игровая минута (тик симуляции).
signal time_ticked(total_minutes: int)
## Сменилась фаза суток (TimeSystem.Phase).
signal phase_changed(day: int, phase: int)
## Начались новые сутки.
signal day_started(day: int)
## Сменилась скорость времени (0 — пауза).
signal time_speed_changed(speed: int)
## Сменился активный герой.
signal active_hero_changed(hero_id: StringName)
## Выполнена команда игрока.
signal command_executed(command: GameCommand)
## Перед сохранением: адаптеры сцены записывают своё состояние в GameState.
signal before_save
## Игра сохранена в слот.
signal game_saved(slot: String)
## Состояние заменено целиком (новая игра или загрузка) — сцены перечитывают его.
signal state_replaced
## Короткое уведомление для HUD (ключ перевода).
signal notify(text_key: String)
