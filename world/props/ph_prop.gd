@tool
class_name PhProp
extends StaticBody2D
## Предмет-заглушка: цветной прямоугольник с подписью. Позже заменяется спрайтом.
## Позиция узла — левый верхний угол предмета.

@export var size: Vector2 = Vector2(32, 32):
	set(value):
		size = value
		_rebuild()
@export var color: Color = Color(0.5, 0.5, 0.5):
	set(value):
		color = value
		_rebuild()
## Ключ перевода подписи.
@export var label_key: String = "":
	set(value):
		label_key = value
		_rebuild()
## Подпись внизу предмета (чтобы не мешала тому, что лежит сверху).
@export var label_at_bottom: bool = false:
	set(value):
		label_at_bottom = value
		_rebuild()
## Можно ли пройти сквозь предмет.
@export var solid: bool = true:
	set(value):
		solid = value
		_rebuild()

var _rect: ColorRect
var _label: Label
var _shape: CollisionShape2D


func _ready() -> void:
	_rect = ColorRect.new()
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 9)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	_shape = CollisionShape2D.new()
	_shape.shape = RectangleShape2D.new()
	add_child(_shape)
	_rebuild()


func _rebuild() -> void:
	if _rect == null:
		return
	_rect.size = size
	_rect.color = color
	_label.size = size
	_label.text = label_key
	_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM if label_at_bottom else VERTICAL_ALIGNMENT_CENTER
	var rect_shape: RectangleShape2D = _shape.shape
	rect_shape.size = size
	_shape.position = size / 2.0
	_shape.disabled = not solid
