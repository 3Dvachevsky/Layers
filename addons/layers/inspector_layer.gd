extends EditorInspectorPlugin




func _can_handle(object: Object) -> bool:
	return object is Layer



func _parse_begin(object: Object) -> void:
	var save_button: Button = Button.new()
	save_button.text = "Save Layer"
	save_button.pressed.connect(save_button_pressed.bind(object))
	add_custom_control(save_button)


func save_button_pressed(layer: Layer):
	layer.save()
