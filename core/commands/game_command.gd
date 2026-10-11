class_name GameCommand
extends RefCounted
## Базовый класс действия игрока. Любое действие — объект команды,
## который сериализуется в словарь: в коопе клиент шлёт его хосту по сети.

## Кто отправил команду (id сетевого пира; 1 — хост или одиночная игра).
var sender_peer: int = 1


## Уникальное имя типа команды — по нему команда восстанавливается из словаря.
func get_type() -> StringName:
	return &""


## Можно ли выполнить команду в текущем состоянии. Хост проверяет каждую команду.
func validate(_session: GameSession) -> bool:
	return true


## Выполнить команду: изменить состояние партии.
func execute(_session: GameSession) -> void:
	pass


## Параметры команды (без типа и отправителя).
func _params_to_dict() -> Dictionary:
	return {}


func _params_from_dict(_data: Dictionary) -> void:
	pass


## Сериализовать в словарь для сети и журналов.
func to_dict() -> Dictionary:
	return {"type": String(get_type()), "sender": sender_peer, "params": _params_to_dict()}


## Заполнить поля из словаря (тип выбирает CommandBus).
func load_dict(data: Dictionary) -> void:
	sender_peer = int(data.get("sender", 1))
	_params_from_dict(data.get("params", {}))
