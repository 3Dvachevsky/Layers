@tool
class_name Layer
extends Node

@export var save_file: PackedScene

var editor_interface = Engine.get_singleton("EditorInterface")

func _ready() -> void:
	if Engine.is_editor_hint():
		var parent: Node = get_parent()
		var is_found: bool = false
		for i in 99:
			if parent is Layer:
				is_found = true
				queue_free()
				printerr("[Layer Plugin]: Layers within layers are not supported")
				break
			if parent == editor_interface.get_edited_scene_root():
				break
			parent = parent.get_parent()
		if is_found:
			return
	if save_file == null:
		if Engine.is_editor_hint():
			dialog_save()
	else:
		if get_child_count() == 0:
			var load: Node = save_file.instantiate()
			for ch in load.get_children():
				add_child(ch.duplicate())
			
			change_owner(owner)
	
	if not Engine.is_editor_hint():
		set_script(null)



func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		change_owner(null)
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		change_owner(owner)


func change_owner(_owner: Node, node: Node = self):
	for ch in node.get_children():
		ch.owner = _owner
		if ch.scene_file_path.is_empty():
			change_owner(_owner, ch)


func save():
	if save_file == null:
		await get_tree().process_frame
		dialog_save()
		return
	
	var save_path: String = save_file.resource_path
	save_file = null
	
	var root_node: Node = Node.new()
	root_node.name = name
	for ch in get_children():
		root_node.add_child(ch.duplicate())
	
	change_owner(root_node, root_node)
	
	var scene: PackedScene = PackedScene.new()
	scene.pack(root_node)
	ResourceSaver.save(scene, save_path)
	editor_interface.call_deferred("reload_scene_from_path", save_path)
	save_file = ResourceLoader.load(save_path)



func dialog_save():
	var file_dialog: FileDialog = FileDialog.new()
	file_dialog.title = "Save layer"
	file_dialog.exclusive = true
	file_dialog.transient = true
	get_tree().root.add_child(file_dialog)
	file_dialog.size = Vector2(800, 450)
	file_dialog.visible = true
	file_dialog.popup_centered()
	file_dialog.filters = PackedStringArray(["*.tscn", "*.scn", "*.res"])
	
	file_dialog.file_selected.connect(func(file: String = ""): 
		file_dialog.queue_free()
		
		if file.get_extension().is_empty():
			file = file + ".tscn"
			if FileAccess.file_exists(file):
				printerr("[Layer Plugin]: File extension is missing, layer is not saved")
				return
		if file.get_file().get_basename().is_empty():
			file = file.get_base_dir() + "/layer." + file.get_extension()
			if FileAccess.file_exists(file):
				printerr("[Layer Plugin]: File name is missing, layer is not saved")
				return
		
		var scene: PackedScene = PackedScene.new()
		scene.resource_path = file
		save_file = scene
		save())
	
	file_dialog.canceled.connect(func(): 
		file_dialog.queue_free()
		printerr("[Layer Plugin]: Layer is not saved"))
	
