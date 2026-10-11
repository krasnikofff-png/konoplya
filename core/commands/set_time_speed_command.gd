class_name SetTimeSpeedCommand
extends GameCommand
## Поменять скорость времени (0 — пауза).

var speed: int = 1


func _init(new_speed: int = 1) -> void:
	speed = new_speed


func get_type() -> StringName:
	return &"set_time_speed"


func validate(session: GameSession) -> bool:
	return session.time_system.is_valid_speed(speed)


func execute(session: GameSession) -> void:
	session.state.time_speed = speed


func _params_to_dict() -> Dictionary:
	return {"speed": speed}


func _params_from_dict(data: Dictionary) -> void:
	speed = int(data.get("speed", 1))
