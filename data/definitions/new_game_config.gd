class_name NewGameConfig
extends Resource
## Стартовые значения новой партии. Баланс правится в data/config/new_game.tres.

## Время начала: минута суток первого дня (480 = 08:00).
@export_range(0, 1439) var start_minute_of_day: int = 480
@export_range(0, 4) var start_time_speed: int = 1
@export var start_money: int = 0
@export_range(0, 100) var start_heat: int = 0
@export_range(0, 100) var start_brotherhood: int = 50
@export var start_active_hero: StringName = &"finn"
