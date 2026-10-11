class_name SaveSystem
extends RefCounted
## Сохранения в JSON. Один слот — один файл <slot>.json в папке сохранений.
## В файле есть версия формата; старые версии проходят через миграции.

const DEFAULT_DIR: String = "user://saves/"

var _dir: String


func _init(save_dir: String = DEFAULT_DIR) -> void:
	_dir = save_dir if save_dir.ends_with("/") else save_dir + "/"


## Путь к файлу слота.
func slot_path(slot: String) -> String:
	return _dir + slot + ".json"


## Есть ли сохранение в слоте.
func has_save(slot: String) -> bool:
	return FileAccess.file_exists(slot_path(slot))


## Сохранить состояние. Пишем во временный файл и переименовываем,
## чтобы сбой посреди записи не испортил старое сохранение.
func save(state: GameState, slot: String) -> Error:
	var err: Error = DirAccess.make_dir_recursive_absolute(_dir)
	if err != OK:
		return err
	var tmp_path: String = slot_path(slot) + ".tmp"
	var file: FileAccess = FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(state.to_dict(), "\t"))
	file.close()
	if FileAccess.file_exists(slot_path(slot)):
		DirAccess.remove_absolute(slot_path(slot))
	return DirAccess.rename_absolute(tmp_path, slot_path(slot))


## Загрузить состояние из слота. null — файла нет, он повреждён или из будущей версии.
func load_state(slot: String) -> GameState:
	if not has_save(slot):
		return null
	var text: String = FileAccess.get_file_as_string(slot_path(slot))
	var json := JSON.new()
	var parsed: Variant = json.data if json.parse(text) == OK else null
	if not parsed is Dictionary:
		push_warning("SaveSystem: файл '%s' повреждён" % slot_path(slot))
		return null
	var data: Dictionary = parsed
	var version: int = int(data.get("version", 0))
	if version > GameState.FORMAT_VERSION:
		push_warning("SaveSystem: сохранение новее игры (версия %d)" % version)
		return null
	return GameState.from_dict(migrate(data))


## Удалить сохранение.
func delete(slot: String) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(slot_path(slot))


## Привести данные старой версии к текущей. Добавлять шаги при росте FORMAT_VERSION.
static func migrate(data: Dictionary) -> Dictionary:
	var version: int = int(data.get("version", 0))
	if version < 1:
		data["version"] = 1
	return data
