class_name SwitchHeroCommand
extends GameCommand
## Переключить управление на другого героя (одиночная игра).
## Пустой hero_id — переключить на следующего по списку.

var hero_id: StringName = &""


func _init(target_hero: StringName = &"") -> void:
	hero_id = target_hero


func get_type() -> StringName:
	return &"switch_hero"


func validate(session: GameSession) -> bool:
	return hero_id == &"" or session.hero_ids.has(hero_id)


func execute(session: GameSession) -> void:
	if hero_id == &"":
		var index: int = session.hero_ids.find(session.state.active_hero)
		session.state.active_hero = session.hero_ids[(index + 1) % session.hero_ids.size()]
	else:
		session.state.active_hero = hero_id


func _params_to_dict() -> Dictionary:
	return {"hero_id": String(hero_id)}


func _params_from_dict(data: Dictionary) -> void:
	hero_id = StringName(str(data.get("hero_id", "")))
