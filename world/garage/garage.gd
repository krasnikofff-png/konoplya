extends Node2D
## Гараж бабушки Нэнси (тестовая сцена M0). Связывает героев в мире
## с состоянием партии: кто активен, где стоят, что записать при сохранении.

var _heroes: Dictionary[StringName, Hero] = {}


func _ready() -> void:
	for child: Node in $Heroes.get_children():
		var hero: Hero = child as Hero
		if hero != null:
			_heroes[hero.data.id] = hero
	EventBus.active_hero_changed.connect(_on_active_hero_changed)
	EventBus.before_save.connect(_on_before_save)
	EventBus.state_replaced.connect(_apply_state)
	_apply_state()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"switch_hero"):
		Game.submit(SwitchHeroCommand.new())
		get_viewport().set_input_as_handled()


## Герой по id (для тестов и других адаптеров).
func get_hero(hero_id: StringName) -> Hero:
	return _heroes.get(hero_id)


## Перечитать состояние: позиции (если сохранены) и активного героя.
func _apply_state() -> void:
	var state: GameState = Game.state()
	for hero_id: StringName in _heroes:
		if state.hero_positions.has(hero_id):
			_heroes[hero_id].position = state.hero_positions[hero_id]
	_on_active_hero_changed(state.active_hero)


func _on_active_hero_changed(active_id: StringName) -> void:
	for hero_id: StringName in _heroes:
		_heroes[hero_id].set_active(hero_id == active_id)


func _on_before_save() -> void:
	for hero_id: StringName in _heroes:
		Game.state().hero_positions[hero_id] = _heroes[hero_id].position
