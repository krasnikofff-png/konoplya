class_name GameSession
extends RefCounted
## Партия целиком: состояние + системы симуляции + шина команд.
## Не зависит от сцен — тесты создают её напрямую.

## Игровые герои в порядке переключения.
const HERO_IDS: Array[StringName] = [&"finn", &"rico"]

var state: GameState
var time_system: TimeSystem
var command_bus: CommandBus
var hero_ids: Array[StringName] = HERO_IDS


func _init(game_state: GameState, time_config: TimeConfig) -> void:
	state = game_state
	time_system = TimeSystem.new(state, time_config)
	command_bus = CommandBus.new(self)
