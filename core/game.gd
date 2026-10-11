extends Node
## Точка входа (автозагрузка Game): держит текущую партию, гонит время,
## принимает команды, сохраняет и загружает. Сигналы систем передаёт в EventBus.

const NEW_GAME_CONFIG: NewGameConfig = preload("res://data/config/new_game.tres")
const TIME_CONFIG: TimeConfig = preload("res://data/config/time_config.tres")
const QUICK_SLOT: String = "quicksave"
const DEFAULT_LOCALE: String = "ru"

var session: GameSession
var save_system: SaveSystem = SaveSystem.new()


func _ready() -> void:
	TranslationServer.set_locale(DEFAULT_LOCALE)
	new_game(randi())


func _process(delta: float) -> void:
	if session != null:
		session.time_system.advance(delta)


## Текущее состояние партии.
func state() -> GameState:
	return session.state


## Время текущей партии.
func time() -> TimeSystem:
	return session.time_system


## Начать новую партию с заданным сидом.
func new_game(game_seed: int) -> void:
	_set_session(GameSession.new(GameState.create_new(NEW_GAME_CONFIG, game_seed), TIME_CONFIG))


## Отправить команду игрока. Возвращает true, если она выполнена.
func submit(command: GameCommand) -> bool:
	return session.command_bus.submit(command)


## Сохранить партию в слот.
func save_game(slot: String = QUICK_SLOT) -> bool:
	EventBus.before_save.emit()
	var err: Error = save_system.save(session.state, slot)
	if err != OK:
		push_warning("Game: не удалось сохранить (%s)" % error_string(err))
		EventBus.notify.emit("NOTIFY_SAVE_FAILED")
		return false
	EventBus.game_saved.emit(slot)
	EventBus.notify.emit("NOTIFY_SAVED")
	return true


## Загрузить партию из слота.
func load_game(slot: String = QUICK_SLOT) -> bool:
	var loaded: GameState = save_system.load_state(slot)
	if loaded == null:
		EventBus.notify.emit("NOTIFY_LOAD_FAILED")
		return false
	_set_session(GameSession.new(loaded, TIME_CONFIG))
	EventBus.notify.emit("NOTIFY_LOADED")
	return true


func _set_session(new_session: GameSession) -> void:
	session = new_session
	session.time_system.ticked.connect(EventBus.time_ticked.emit)
	session.time_system.day_started.connect(EventBus.day_started.emit)
	session.time_system.phase_changed.connect(_on_phase_changed)
	session.command_bus.executed.connect(_on_command_executed)
	EventBus.state_replaced.emit()


func _on_phase_changed(day: int, phase: TimeSystem.Phase) -> void:
	EventBus.phase_changed.emit(day, phase)


func _on_command_executed(command: GameCommand) -> void:
	EventBus.command_executed.emit(command)
	if command is SwitchHeroCommand:
		EventBus.active_hero_changed.emit(session.state.active_hero)
	elif command is SetTimeSpeedCommand:
		EventBus.time_speed_changed.emit(session.state.time_speed)
