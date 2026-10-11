extends CanvasLayer
## HUD: день, фаза и часы, скорость времени, деньги, активный герой, уведомления.
## Горячие клавиши времени и сохранения тоже здесь — это слой ввода, не логика.

const NOTIFY_SECONDS: float = 2.5

## Скорость, к которой вернуться после паузы.
var _speed_before_pause: int = 1

@onready var _day_label: Label = %DayLabel
@onready var _speed_label: Label = %SpeedLabel
@onready var _money_label: Label = %MoneyLabel
@onready var _hero_label: Label = %HeroLabel
@onready var _notify_label: Label = %NotifyLabel
@onready var _notify_timer: Timer = %NotifyTimer
@onready var _pause_button: Button = %PauseButton
@onready var _x1_button: Button = %X1Button
@onready var _x2_button: Button = %X2Button
@onready var _x4_button: Button = %X4Button


func _ready() -> void:
	_pause_button.pressed.connect(_set_speed.bind(0))
	_x1_button.pressed.connect(_set_speed.bind(1))
	_x2_button.pressed.connect(_set_speed.bind(2))
	_x4_button.pressed.connect(_set_speed.bind(4))
	_notify_timer.timeout.connect(_notify_label.hide)
	EventBus.time_ticked.connect(_on_time_ticked)
	EventBus.time_speed_changed.connect(_on_speed_changed)
	EventBus.active_hero_changed.connect(_on_hero_changed)
	EventBus.state_replaced.connect(_refresh_all)
	EventBus.notify.connect(_show_notification)
	_notify_label.hide()
	_refresh_all()


func _unhandled_input(event: InputEvent) -> void:
	var handled: bool = true
	if event.is_action_pressed(&"time_pause"):
		_toggle_pause()
	elif event.is_action_pressed(&"time_speed_1"):
		_set_speed(1)
	elif event.is_action_pressed(&"time_speed_2"):
		_set_speed(2)
	elif event.is_action_pressed(&"time_speed_4"):
		_set_speed(4)
	elif event.is_action_pressed(&"quick_save"):
		Game.save_game()
	elif event.is_action_pressed(&"quick_load"):
		Game.load_game()
	else:
		handled = false
	if handled:
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	if Game.state().time_speed == 0:
		_set_speed(_speed_before_pause)
	else:
		_set_speed(0)


func _set_speed(speed: int) -> void:
	var current: int = Game.state().time_speed
	if speed == 0 and current > 0:
		_speed_before_pause = current
	Game.submit(SetTimeSpeedCommand.new(speed))


func _refresh_all() -> void:
	_on_time_ticked(Game.state().total_minutes)
	_on_speed_changed(Game.state().time_speed)
	_on_hero_changed(Game.state().active_hero)


func _on_time_ticked(_total_minutes: int) -> void:
	var time: TimeSystem = Game.time()
	_day_label.text = tr("HUD_DAY") % [time.get_day(), tr(TimeSystem.phase_key(time.get_phase())), time.get_hour(), time.get_minute()]
	_money_label.text = tr("HUD_MONEY") % Game.state().money


func _on_speed_changed(speed: int) -> void:
	_speed_label.text = tr("HUD_PAUSED") if speed == 0 else tr("HUD_SPEED") % speed


func _on_hero_changed(hero_id: StringName) -> void:
	_hero_label.text = tr("HUD_ACTIVE_HERO") % tr("HERO_" + String(hero_id).to_upper())


func _show_notification(text_key: String) -> void:
	_notify_label.text = tr(text_key)
	_notify_label.show()
	_notify_timer.start(NOTIFY_SECONDS)
