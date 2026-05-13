extends Node

signal tab_switched(tab_name)

var tab_scenes = { }
var content_area: Node = null
var current_tab: String = ""
var current_instance: Node = null


func setup(_content_area: Node, _tab_scenes: Dictionary):
	content_area = _content_area
	tab_scenes = _tab_scenes


func switch_tab(tab_name: String):
	if not tab_scenes.has(tab_name):
		push_error("No such tab: %s" % tab_name)
		return

	if current_tab == tab_name:
		return

	# Remove previous tab
	if current_instance and current_instance.get_parent():
		current_instance.queue_free()
		current_instance = null

	# Instance and add new
	var scene_res = tab_scenes[tab_name]
	if not scene_res:
		push_error("Scene resource for tab not loaded: %s" % tab_name)
		return

	current_instance = scene_res.instantiate()
	content_area.add_child(current_instance)
	current_tab = tab_name
	emit_signal("tab_switched", tab_name)
