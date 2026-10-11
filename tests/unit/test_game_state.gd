extends GutTest
## Тесты сериализации состояния партии.


func _make_state() -> GameState:
	var state := GameState.create_new(NewGameConfig.new(), 123)
	state.total_minutes = 5000
	state.time_speed = 2
	state.money = 1500
	state.heat = 37
	state.brotherhood = 64
	state.relationships[&"briggs"] = -20
	state.story_flags[&"criminal_record"] = true
	state.active_hero = &"rico"
	state.hero_positions[&"finn"] = Vector2(10.5, 20.0)
	state.hero_positions[&"rico"] = Vector2(300.0, 200.25)
	return state


func test_create_new_uses_config() -> void:
	var config := NewGameConfig.new()
	config.start_money = 77
	config.start_minute_of_day = 480
	var state := GameState.create_new(config, 1)
	assert_eq(state.money, 77)
	assert_eq(state.total_minutes, 480)
	assert_eq(state.rng.get_seed(), 1)


func test_roundtrip_through_json() -> void:
	var original := _make_state()
	var data: Dictionary = JSON.parse_string(JSON.stringify(original.to_dict()))
	var restored := GameState.from_dict(data)
	assert_eq(restored.to_dict(), original.to_dict())
	assert_eq(restored.active_hero, &"rico")
	assert_eq(restored.hero_positions[&"rico"], Vector2(300.0, 200.25))
	assert_eq(restored.relationships[&"briggs"], -20)
	assert_eq(restored.story_flags[&"criminal_record"], true)


func test_dict_has_version() -> void:
	assert_eq(_make_state().to_dict()["version"], GameState.FORMAT_VERSION)
