class_name Kusher
extends Node2D
## Кот Кушер — талисман без механики. Спит на мешках с грунтом
## и иногда перебирается на другое место. Случайность здесь чисто декоративная,
## поэтому свой генератор, а не игровой (не влияет на симуляцию и сохранения).

## Места, где кот любит лежать. Первое — любимое (мешки с грунтом).
@export var spots: Array[Vector2] = []
## Через сколько секунд кот может сменить место (от и до).
@export var nap_seconds_min: float = 12.0
@export var nap_seconds_max: float = 25.0
## Скорость перехода, пикселей в секунду.
@export var walk_speed: float = 40.0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _timer: Timer
var _spot_index: int = 0

@onready var _zzz: Label = $Zzz


func _ready() -> void:
	_rng.randomize()
	if not spots.is_empty():
		position = spots[0]
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_on_nap_over)
	add_child(_timer)
	_start_nap()


func _start_nap() -> void:
	_zzz.visible = true
	_timer.start(_rng.randf_range(nap_seconds_min, nap_seconds_max))


func _on_nap_over() -> void:
	if spots.size() < 2:
		_start_nap()
		return
	# Чаще возвращается на любимые мешки.
	var next: int = 0 if _spot_index != 0 and _rng.randf() < 0.5 else _rng.randi_range(0, spots.size() - 1)
	if next == _spot_index:
		next = (next + 1) % spots.size()
	_spot_index = next
	_zzz.visible = false
	var target: Vector2 = spots[next]
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target, position.distance_to(target) / walk_speed)
	tween.tween_callback(_start_nap)
