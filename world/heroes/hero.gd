class_name Hero
extends CharacterBody2D
## Герой в мире. Тонкий адаптер: показывает заглушку и двигает героя,
## когда им управляет игрок. Неактивный герой стоит на месте.

const BODY_SIZE: Vector2 = Vector2(24, 24)

@export var data: HeroData

var is_active: bool = false

@onready var _body: ColorRect = $Body
@onready var _letter: Label = $Body/Letter
@onready var _marker: Polygon2D = $ActiveMarker


func _ready() -> void:
	_body.color = data.color
	_letter.text = data.letter_key
	set_active(false)


## Отдать или забрать управление.
func set_active(active: bool) -> void:
	is_active = active
	_marker.visible = active
	if not active:
		velocity = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	if not is_active:
		return
	var direction: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	velocity = direction * data.move_speed
	move_and_slide()
