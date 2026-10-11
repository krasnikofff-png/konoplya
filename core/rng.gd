class_name GameRng
extends RefCounted
## Единый генератор случайных чисел игры. Сид и внутреннее состояние
## сохраняются вместе с игрой, поэтому результаты воспроизводимы.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _seed: int = 0


func _init(game_seed: int = 0) -> void:
	reseed(game_seed)


## Задать новый сид и сбросить последовательность.
func reseed(game_seed: int) -> void:
	_seed = game_seed
	_rng.seed = game_seed


## Сид, с которого началась последовательность.
func get_seed() -> int:
	return _seed


## Целое число в диапазоне [from, to] включительно.
func range_int(from: int, to: int) -> int:
	return _rng.randi_range(from, to)


## Дробное число в диапазоне [from, to].
func range_float(from: float, to: float) -> float:
	return _rng.randf_range(from, to)


## Дробное число в диапазоне [0, 1).
func value() -> float:
	return _rng.randf()


## true с вероятностью probability (0–1).
func chance(probability: float) -> bool:
	return _rng.randf() < probability


## Состояние для сохранения. Строки — чтобы 64-битные числа не теряли точность в JSON.
func to_dict() -> Dictionary:
	return {"seed": str(_seed), "state": str(_rng.state)}


## Восстановить сид и позицию в последовательности.
func from_dict(data: Dictionary) -> void:
	_seed = str(data.get("seed", "0")).to_int()
	_rng.seed = _seed
	_rng.state = str(data.get("state", "0")).to_int()
