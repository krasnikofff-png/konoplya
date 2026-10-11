extends GutTest
## Тесты шины команд.

var _session: GameSession


func before_each() -> void:
	_session = GameSession.new(GameState.create_new(NewGameConfig.new(), 1), TimeConfig.new())


func test_switch_hero_cycles() -> void:
	assert_eq(_session.state.active_hero, &"finn")
	assert_true(_session.command_bus.submit(SwitchHeroCommand.new()))
	assert_eq(_session.state.active_hero, &"rico")
	_session.command_bus.submit(SwitchHeroCommand.new())
	assert_eq(_session.state.active_hero, &"finn")


func test_switch_to_specific_hero() -> void:
	_session.command_bus.submit(SwitchHeroCommand.new(&"rico"))
	assert_eq(_session.state.active_hero, &"rico")


func test_unknown_hero_rejected() -> void:
	watch_signals(_session.command_bus)
	assert_false(_session.command_bus.submit(SwitchHeroCommand.new(&"gloria")))
	assert_eq(_session.state.active_hero, &"finn")
	assert_signal_emitted(_session.command_bus, "rejected")


func test_set_speed() -> void:
	assert_true(_session.command_bus.submit(SetTimeSpeedCommand.new(4)))
	assert_eq(_session.state.time_speed, 4)
	assert_true(_session.command_bus.submit(SetTimeSpeedCommand.new(0)))
	assert_eq(_session.state.time_speed, 0)


func test_invalid_speed_rejected() -> void:
	assert_false(_session.command_bus.submit(SetTimeSpeedCommand.new(3)))
	assert_eq(_session.state.time_speed, 1)


func test_command_roundtrip_through_dict() -> void:
	var original := SetTimeSpeedCommand.new(2)
	original.sender_peer = 5
	var data: Dictionary = JSON.parse_string(JSON.stringify(original.to_dict()))
	var restored := _session.command_bus.create(data)
	assert_true(restored is SetTimeSpeedCommand)
	assert_eq((restored as SetTimeSpeedCommand).speed, 2)
	assert_eq(restored.sender_peer, 5)


func test_unknown_command_type() -> void:
	assert_null(_session.command_bus.create({"type": "launch_rocket"}))
	assert_push_warning("неизвестная команда")


func test_executed_signal() -> void:
	watch_signals(_session.command_bus)
	_session.command_bus.submit(SwitchHeroCommand.new())
	assert_signal_emitted(_session.command_bus, "executed")
