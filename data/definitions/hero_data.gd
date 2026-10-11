class_name HeroData
extends Resource
## Игровой герой: имя, вид заглушки, скорость, своя сфера работы.

@export var id: StringName = &""
## Ключ перевода имени.
@export var name_key: String = ""
## Ключ перевода буквы на заглушке.
@export var letter_key: String = ""
## Цвет заглушки.
@export var color: Color = Color.WHITE
## Скорость ходьбы, пикселей в секунду.
@export var move_speed: float = 120.0
## Множитель для работы в своей сфере (используется с этапа M1).
@export var specialty_multiplier: float = 1.5
