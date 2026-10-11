extends GutTest
## Тесты генератора случайных чисел.


func _sequence(rng: GameRng, count: int) -> Array[int]:
	var result: Array[int] = []
	for i: int in count:
		result.append(rng.range_int(0, 1_000_000))
	return result


func test_same_seed_same_sequence() -> void:
	assert_eq(_sequence(GameRng.new(42), 20), _sequence(GameRng.new(42), 20))


func test_different_seeds_differ() -> void:
	assert_ne(_sequence(GameRng.new(1), 20), _sequence(GameRng.new(2), 20))


func test_restores_position_in_sequence() -> void:
	var rng := GameRng.new(7)
	_sequence(rng, 5)
	var saved: Dictionary = rng.to_dict()
	var expected: Array[int] = _sequence(rng, 10)
	var restored := GameRng.new()
	restored.from_dict(saved)
	assert_eq(restored.get_seed(), 7)
	assert_eq(_sequence(restored, 10), expected)


func test_large_seed_survives_json() -> void:
	var rng := GameRng.new(9_007_199_254_740_993)
	_sequence(rng, 3)
	var through_json: Dictionary = JSON.parse_string(JSON.stringify(rng.to_dict()))
	var restored := GameRng.new()
	restored.from_dict(through_json)
	assert_eq(_sequence(restored, 5), _sequence(rng, 5))


func test_chance_bounds() -> void:
	var rng := GameRng.new(3)
	for i: int in 100:
		assert_false(rng.chance(0.0))
		assert_true(rng.chance(1.0))
