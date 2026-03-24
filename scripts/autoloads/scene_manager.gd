extends Node

signal tab_switched(tab_name)

var tab_scenes = {}
var content_area : Node = null
var current_tab : String = ""
var tab_instances: Dictionary = {}

func setup(_content_area : Node, _tab_scenes : Dictionary):
	content_area = _content_area
	tab_scenes = _tab_scenes

func switch_tab(tab_name: String):
	if not tab_scenes.has(tab_name):
		push_error("No such tab: %s" % tab_name)
		return

	if current_tab == tab_name:
		return

	if current_tab != "" and tab_instances.has(current_tab):
		_set_tab_visual_state(tab_instances[current_tab], false)

	if not tab_instances.has(tab_name):
		var scene_res: PackedScene = tab_scenes[tab_name]
		if not scene_res:
			push_error("Scene resource for tab not loaded: %s" % tab_name)
			return
		var instance = scene_res.instantiate()
		content_area.add_child(instance)
		tab_instances[tab_name] = instance

	_set_tab_visual_state(tab_instances[tab_name], true)
	current_tab = tab_name
	emit_signal("tab_switched", tab_name)

func _set_tab_visual_state(root: Node, is_visible: bool) -> void:
	if root is CanvasItem:
		(root as CanvasItem).visible = is_visible

	for child in root.get_children():
		_set_canvas_layers_visible(child, is_visible)

func _set_canvas_layers_visible(node: Node, is_visible: bool) -> void:
	if node is CanvasLayer:
		(node as CanvasLayer).visible = is_visible
	for child in node.get_children():
		_set_canvas_layers_visible(child, is_visible)

func get_tab_instance(tab_name: String) -> Node:
	return tab_instances.get(tab_name, null)
