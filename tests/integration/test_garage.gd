extends GutTest
## Проверка тестовой сцены: два героя, переключение, сохранение позиций.

const MAIN_SCENE: PackedScene = preload("res://world/main.tscn")
const TEST_DIR: String = "user://test_saves/"

var _main: Node
var _garage: Node2D
var _original_saves: SaveSystem


func before_each() -> void:
	Game.new_game(1)
	_original_saves = Game.save_system
	Game.save_system = SaveSystem.new(TEST_DIR)
	_main = add_child_autofree(MAIN_SCENE.instantiate())
	_garage = _main.get_node("Garage")


func after_each() -> void:
	Game.save_system.delete(Game.QUICK_SLOT)
	Game.save_system = _original_saves


func _hero(hero_id: StringName) -> Hero:
	return _garage.call("get_hero", hero_id)


func test_two_heroes_and_cat() -> void:
	assert_not_null(_hero(&"finn"))
	assert_not_null(_hero(&"rico"))
	assert_not_null(_garage.get_node("Kusher"))


func test_finn_starts_active() -> void:
	assert_true(_hero(&"finn").is_active)
	assert_false(_hero(&"rico").is_active)


func test_switch_hero_updates_scene() -> void:
	Game.submit(SwitchHeroCommand.new())
	assert_false(_hero(&"finn").is_active)
	assert_true(_hero(&"rico").is_active)


func test_tab_switches_hero() -> void:
	var event := InputEventAction.new()
	event.action = &"switch_hero"
	event.pressed = true
	Input.parse_input_event(event)
	await wait_physics_frames(2)
	assert_true(_hero(&"rico").is_active)


func test_save_and_load_restores_positions_and_hero() -> void:
	_hero(&"finn").position = Vector2(100, 150)
	Game.submit(SwitchHeroCommand.new(&"rico"))
	assert_true(Game.save_game())
	_hero(&"finn").position = Vector2(500, 300)
	Game.submit(SwitchHeroCommand.new(&"finn"))
	assert_true(Game.load_game())
	assert_eq(_hero(&"finn").position, Vector2(100, 150))
	assert_true(_hero(&"rico").is_active)


func test_time_runs() -> void:
	var before: int = Game.state().total_minutes
	Game.time().advance(5.0)
	assert_gt(Game.state().total_minutes, before)
