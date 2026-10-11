class_name GameState
extends RefCounted
## Полное состояние партии. Системы читают и меняют его; сохранение — это
## сериализация этого объекта в словарь и JSON.

## Версия формата сохранения. Увеличивать при несовместимых изменениях
## и добавлять миграцию в SaveSystem.
const FORMAT_VERSION: int = 1

## Игровое время: минуты с начала партии (0 = день 1, 00:00).
var total_minutes: int = 0
## Скорость времени: 0 — пауза, 1, 2, 4.
var time_speed: int = 1
var money: int = 0
## Жар (0–100). После легализации становится regulator_reputation.
var heat: int = 0
## Братство героев (0–100).
var brotherhood: int = 50
## Отношения с NPC: id → −100…100.
var relationships: Dictionary[StringName, int] = {}
## Сюжетные флаги: имя → значение (bool, int или String).
var story_flags: Dictionary[StringName, Variant] = {}
## Герой под управлением игрока (в одиночной игре).
var active_hero: StringName = &"finn"
## Позиции героев в мире.
var hero_positions: Dictionary[StringName, Vector2] = {}
## Единый генератор случайных чисел.
var rng: GameRng = GameRng.new()


## Создать состояние новой партии по стартовым настройкам.
static func create_new(config: NewGameConfig, game_seed: int) -> GameState:
	var state := GameState.new()
	state.total_minutes = config.start_minute_of_day
	state.time_speed = config.start_time_speed
	state.money = config.start_money
	state.heat = config.start_heat
	state.brotherhood = config.start_brotherhood
	state.active_hero = config.start_active_hero
	state.rng.reseed(game_seed)
	return state


## Сериализовать в словарь из простых типов (готов для JSON).
func to_dict() -> Dictionary:
	var positions: Dictionary = {}
	for hero_id: StringName in hero_positions:
		var pos: Vector2 = hero_positions[hero_id]
		positions[String(hero_id)] = [pos.x, pos.y]
	var rel: Dictionary = {}
	for npc_id: StringName in relationships:
		rel[String(npc_id)] = relationships[npc_id]
	var flags: Dictionary = {}
	for flag: StringName in story_flags:
		flags[String(flag)] = story_flags[flag]
	return {
		"version": FORMAT_VERSION,
		"time": {"total_minutes": total_minutes, "speed": time_speed},
		"money": money,
		"heat": heat,
		"brotherhood": brotherhood,
		"relationships": rel,
		"story_flags": flags,
		"active_hero": String(active_hero),
		"hero_positions": positions,
		"rng": rng.to_dict(),
	}


## Восстановить из словаря (после JSON все числа приходят как float — приводим).
static func from_dict(data: Dictionary) -> GameState:
	var state := GameState.new()
	var time: Dictionary = data.get("time", {})
	state.total_minutes = int(time.get("total_minutes", 0))
	state.time_speed = int(time.get("speed", 1))
	state.money = int(data.get("money", 0))
	state.heat = int(data.get("heat", 0))
	state.brotherhood = int(data.get("brotherhood", 50))
	var rel: Dictionary = data.get("relationships", {})
	for npc_id: String in rel:
		state.relationships[StringName(npc_id)] = int(rel[npc_id])
	var flags: Dictionary = data.get("story_flags", {})
	for flag: String in flags:
		state.story_flags[StringName(flag)] = flags[flag]
	state.active_hero = StringName(str(data.get("active_hero", "finn")))
	var positions: Dictionary = data.get("hero_positions", {})
	for hero_id: String in positions:
		var xy: Array = positions[hero_id]
		state.hero_positions[StringName(hero_id)] = Vector2(float(xy[0]), float(xy[1]))
	state.rng.from_dict(data.get("rng", {}))
	return state
