@tool
extends EditorPlugin


var inspector_layer

func _enter_tree():
	add_custom_type("Layer", "Node", preload("res://addons/layers/layer_node.gd"), preload("res://addons/layers/layer_icon.png"))
	inspector_layer = preload("res://addons/layers/inspector_layer.gd").new()
	add_inspector_plugin(inspector_layer)


func _exit_tree():
	remove_custom_type("Layer")
	remove_inspector_plugin(inspector_layer)
