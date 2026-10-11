extends GutTest
## Проверка, что аддон Dialogue Manager подключён и разбирает диалоги.
## Это технический тест: реплики здесь служебные, не сюжетные.


func test_dialogue_compiles_and_runs() -> void:
	var text: String = "~ start\nTester: Line one\nTester: Line two\n=> END\n"
	var resource: DialogueResource = DialogueManager.create_resource_from_text(text)
	assert_not_null(resource)
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "start")
	assert_not_null(line)
	assert_eq(line.character, "Tester")
	assert_eq(line.text, "Line one")
	var next: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
	assert_eq(next.text, "Line two")
