class_name TimeSystem
extends RefCounted
## Игровое время. Симуляция идёт фиксированными тиками по одной игровой минуте;
## реальное время превращается в тики через advance(). От сцен не зависит.

enum Phase { MORNING, DAY, EVENING, NIGHT }

const MINUTES_PER_DAY: int = 1440
const SEASONS_PER_YEAR: int = 4

## Каждый тик (одна игровая минута).
signal ticked(total_minutes: int)
## Начались новые сутки.
signal day_started(day: int)
## Сменилась фаза суток.
signal phase_changed(day: int, phase: Phase)

var _state: GameState
var _config: TimeConfig
var _accumulator: float = 0.0


func _init(state: GameState, config: TimeConfig) -> void:
	_state = state
	_config = config


## Длина одного тика в реальных секундах на скорости ×1.
func tick_seconds() -> float:
	return _config.real_seconds_per_day / float(MINUTES_PER_DAY)


## Перевести прошедшее реальное время в тики. Возвращает число выполненных тиков.
func advance(real_delta: float) -> int:
	if _state.time_speed <= 0:
		return 0
	_accumulator += real_delta * float(_state.time_speed)
	var step: float = tick_seconds()
	var done: int = 0
	while _accumulator >= step and done < _config.max_ticks_per_frame:
		_accumulator -= step
		tick()
		done += 1
	if done >= _config.max_ticks_per_frame:
		_accumulator = minf(_accumulator, step)
	return done


## Один шаг симуляции: +1 игровая минута.
func tick() -> void:
	var old_day: int = get_day()
	var old_phase: Phase = get_phase()
	_state.total_minutes += 1
	ticked.emit(_state.total_minutes)
	var new_day: int = get_day()
	if new_day != old_day:
		day_started.emit(new_day)
	var new_phase: Phase = get_phase()
	if new_phase != old_phase:
		phase_changed.emit(new_day, new_phase)


## Можно ли поставить такую скорость (0 — пауза).
func is_valid_speed(speed: int) -> bool:
	return speed == 0 or _config.speeds.has(speed)


## Номер игрового дня, начиная с 1.
func get_day() -> int:
	return _state.total_minutes / MINUTES_PER_DAY + 1


## Минута текущих суток (0–1439).
func get_minute_of_day() -> int:
	return _state.total_minutes % MINUTES_PER_DAY


func get_hour() -> int:
	return get_minute_of_day() / 60


func get_minute() -> int:
	return get_minute_of_day() % 60


## Текущая фаза суток.
func get_phase() -> Phase:
	return phase_for_minute(get_minute_of_day())


## Фаза суток для минуты от полуночи.
func phase_for_minute(minute_of_day: int) -> Phase:
	if minute_of_day >= _config.night_start or minute_of_day < _config.morning_start:
		return Phase.NIGHT
	if minute_of_day >= _config.evening_start:
		return Phase.EVENING
	if minute_of_day >= _config.day_start:
		return Phase.DAY
	return Phase.MORNING


## Сезон: 0 весна, 1 лето, 2 осень, 3 зима.
func get_season() -> int:
	return ((get_day() - 1) / _config.days_per_season) % SEASONS_PER_YEAR


## Номер игрового года, начиная с 1.
func get_year() -> int:
	return (get_day() - 1) / (_config.days_per_season * SEASONS_PER_YEAR) + 1


## Ключ перевода для названия фазы.
static func phase_key(phase: Phase) -> String:
	return "PHASE_" + Phase.keys()[phase]
