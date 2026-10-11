extends GutTest
## Тесты сохранений. Пишут во временную папку, не трогая сохранения игрока.

const TEST_DIR: String = "user://test_saves/"

var _saves: SaveSystem


func before_each() -> void:
	_saves = SaveSystem.new(TEST_DIR)


func after_each() -> void:
	for slot: String in ["slot1", "broken", "future", "old"]:
		_saves.delete(slot)


func _write_raw(slot: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	var file := FileAccess.open(_saves.slot_path(slot), FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_save_and_load_roundtrip() -> void:
	var state := GameState.create_new(NewGameConfig.new(), 99)
	state.money = 420
	state.hero_positions[&"finn"] = Vector2(1, 2)
	state.rng.range_int(0, 100)
	assert_eq(_saves.save(state, "slot1"), OK)
	assert_true(_saves.has_save("slot1"))
	var loaded := _saves.load_state("slot1")
	assert_not_null(loaded)
	assert_eq(loaded.to_dict(), state.to_dict())
	# Случайность продолжается с того же места.
	assert_eq(loaded.rng.range_int(0, 1000), state.rng.range_int(0, 1000))


func test_overwrite_slot() -> void:
	var state := GameState.new()
	state.money = 1
	_saves.save(state, "slot1")
	state.money = 2
	_saves.save(state, "slot1")
	assert_eq(_saves.load_state("slot1").money, 2)
	assert_false(FileAccess.file_exists(_saves.slot_path("slot1") + ".tmp"))


func test_missing_slot_returns_null() -> void:
	assert_null(_saves.load_state("nope"))


func test_broken_file_returns_null() -> void:
	_write_raw("broken", "{ это не json")
	assert_null(_saves.load_state("broken"))


func test_future_version_is_rejected() -> void:
	_write_raw("future", JSON.stringify({"version": GameState.FORMAT_VERSION + 1}))
	assert_null(_saves.load_state("future"))


func test_old_version_is_migrated() -> void:
	_write_raw("old", JSON.stringify({"money": 5}))
	var loaded := _saves.load_state("old")
	assert_not_null(loaded)
	assert_eq(loaded.money, 5)
