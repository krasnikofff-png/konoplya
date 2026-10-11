class_name CommandBus
extends RefCounted
## Шина команд. В одиночной игре команды выполняются сразу; в коопе (M2)
## клиент отправит словарь команды хосту, а хост восстановит её через create().

## Команда выполнена.
signal executed(command: GameCommand)
## Команда отклонена проверкой.
signal rejected(command: GameCommand)

## Слабая ссылка: партия владеет шиной, а не наоборот (иначе цикл и утечка памяти).
var _session_ref: WeakRef
## Тип команды → скрипт класса команды.
var _registry: Dictionary[StringName, GDScript] = {}


func _init(session: GameSession) -> void:
	_session_ref = weakref(session)
	register(&"set_time_speed", SetTimeSpeedCommand)
	register(&"switch_hero", SwitchHeroCommand)


## Зарегистрировать тип команды, чтобы восстанавливать её из словаря.
func register(type: StringName, script: GDScript) -> void:
	_registry[type] = script


## Создать команду из словаря. null — неизвестный тип.
func create(data: Dictionary) -> GameCommand:
	var type := StringName(str(data.get("type", "")))
	if not _registry.has(type):
		push_warning("CommandBus: неизвестная команда '%s'" % type)
		return null
	var command: GameCommand = _registry[type].new()
	command.load_dict(data)
	return command


## Проверить и выполнить команду. Возвращает true, если выполнена.
func submit(command: GameCommand) -> bool:
	var session: GameSession = _session_ref.get_ref()
	if command == null or session == null or not command.validate(session):
		rejected.emit(command)
		return false
	command.execute(session)
	executed.emit(command)
	return true
