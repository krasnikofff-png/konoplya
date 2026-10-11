class_name TimeConfig
extends Resource
## Настройки игрового времени. Баланс правится в data/config/time_config.tres.

## Сколько реальных секунд длятся одни игровые сутки на скорости ×1.
@export var real_seconds_per_day: float = 360.0
## Допустимые скорости времени (0 — пауза не входит, она всегда есть).
@export var speeds: Array[int] = [1, 2, 4]
## Начало фаз суток, в минутах от полуночи.
@export_range(0, 1439) var morning_start: int = 360
@export_range(0, 1439) var day_start: int = 600
@export_range(0, 1439) var evening_start: int = 1080
@export_range(0, 1439) var night_start: int = 1320
## Длина сезона в днях (сезоны нужны с этапа M6; значение уточняется с автором).
@export var days_per_season: int = 30
## Защита от «спирали»: максимум тиков за один кадр.
@export var max_ticks_per_frame: int = 64
