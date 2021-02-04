extends Control

var lookup_dict: Dictionary
var info_dict := Dictionary()

func _ready():
	_prepare_strokes()
	_prepare_info()

func _prepare_strokes():
	var file = File.new()
	file.open("res://visualmandarin_index.json", file.READ)
	var json = file.get_as_text()
	file.close()
	lookup_dict = JSON.parse(json).result

func _prepare_info():
	var file = File.new()
	file.open("res://Unihan_Readings.txt", file.READ)
	while !file.eof_reached():
		var csv_line: PoolStringArray = file.get_csv_line("	")
		var character_code := csv_line[0].replace("\\u", "0x")
		var character_int = character_code.hex_to_int()
		var character = str(char(character_int))
		if not info_dict.has(character):
			info_dict[character] = ""
		var new_string = info_dict[character] +"\n" + csv_line[1] + ": " + csv_line[2]
		info_dict[character] = new_string

func _on_Button_pressed():
	$AnimationPlayer.play("Show")
	var text = $VBoxContainer/TextEdit.get_selection_text()
	if text.length() > 1:
		$Panel/VBoxContainer/Description.text = str("You should select 1 character. But ", text, "was selected.")
		$Panel/VBoxContainer/TextureRect.hide()
		return

	if lookup_dict.has(text):
		$Panel/VBoxContainer/TextureRect.show()
		var file = str("res://", lookup_dict[text])
		$Panel/VBoxContainer/TextureRect.texture = load(file)
	else:
		$Panel/VBoxContainer/TextureRect.hide()

	if info_dict.has(text):
		$Panel/VBoxContainer/Description.text = info_dict[text]
	else:
		$Panel/VBoxContainer/Description.text = str(text, " not found in dictionary")

func _on_Panel_gui_input(event: InputEvent):
	if event is InputEventMouseButton && event.pressed:
		$AnimationPlayer.play_backwards("Show")
