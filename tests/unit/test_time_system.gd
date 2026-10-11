extends GutTest
## Тесты игрового времени.

var _state: GameState
var _config: TimeConfig
var _time: TimeSystem


func before_each() -> void:
	_state = GameState.new()
	_config = TimeConfig.new()
	_time = TimeSystem.new(_state, _config)


func test_starts_on_day_one_at_midnight() -> void:
	assert_eq(_time.get_day(), 1)
	assert_eq(_time.get_hour(), 0)
	assert_eq(_time.get_phase(), TimeSystem.Phase.NIGHT)


func test_tick_adds_one_minute() -> void:
	_time.tick()
	assert_eq(_state.total_minutes, 1)
	assert_eq(_time.get_minute(), 1)


func test_phase_boundaries() -> void:
	assert_eq(_time.phase_for_minute(_config.morning_start - 1), TimeSystem.Phase.NIGHT)
	assert_eq(_time.phase_for_minute(_config.morning_start), TimeSystem.Phase.MORNING)
	assert_eq(_time.phase_for_minute(_config.day_start), TimeSystem.Phase.DAY)
	assert_eq(_time.phase_for_minute(_config.evening_start), TimeSystem.Phase.EVENING)
	assert_eq(_time.phase_for_minute(_config.night_start), TimeSystem.Phase.NIGHT)


func test_day_rollover_emits_day_started() -> void:
	watch_signals(_time)
	_state.total_minutes = TimeSystem.MINUTES_PER_DAY - 1
	_time.tick()
	assert_eq(_time.get_day(), 2)
	assert_signal_emitted_with_parameters(_time, "day_started", [2])


func test_phase_change_emits_signal() -> void:
	watch_signals(_time)
	_state.total_minutes = _config.morning_start - 1
	_time.tick()
	assert_signal_emitted_with_parameters(_time, "phase_changed", [1, TimeSystem.Phase.MORNING])


func test_pause_stops_time() -> void:
	_state.time_speed = 0
	assert_eq(_time.advance(10.0), 0)
	assert_eq(_state.total_minutes, 0)


func test_one_real_day_at_x1_is_one_game_day() -> void:
	_state.time_speed = 1
	var frames: int = int(_config.real_seconds_per_day * 60.0)
	for i: int in frames:
		_time.advance(1.0 / 60.0)
	# Допуск в одну минуту на погрешность дробей.
	assert_almost_eq(_state.total_minutes, TimeSystem.MINUTES_PER_DAY, 1)


func test_speed_multiplies_ticks() -> void:
	var one_second: float = 1.0
	_state.time_speed = 1
	var at_x1: int = _time.advance(one_second)
	_state.total_minutes = 0
	_state.time_speed = 4
	var at_x4: int = TimeSystem.new(_state, _config).advance(one_second)
	assert_eq(at_x4, at_x1 * 4)


func test_long_frame_is_capped() -> void:
	_state.time_speed = 4
	var done: int = _time.advance(1000.0)
	assert_eq(done, _config.max_ticks_per_frame)


func test_valid_speeds() -> void:
	assert_true(_time.is_valid_speed(0))
	assert_true(_time.is_valid_speed(1))
	assert_true(_time.is_valid_speed(2))
	assert_true(_time.is_valid_speed(4))
	assert_false(_time.is_valid_speed(3))
	assert_false(_time.is_valid_speed(-1))


func test_seasons_and_years() -> void:
	_config.days_per_season = 30
	assert_eq(_time.get_season(), 0)
	_state.total_minutes = 30 * TimeSystem.MINUTES_PER_DAY
	assert_eq(_time.get_day(), 31)
	assert_eq(_time.get_season(), 1)
	_state.total_minutes = 120 * TimeSystem.MINUTES_PER_DAY
	assert_eq(_time.get_season(), 0)
	assert_eq(_time.get_year(), 2)
