extends Node2D

@onready var content = $CanvasLayer

var battle_area_scene := preload("res://scenes/battle_area.tscn")
var level_select_scene := preload("res://scenes/battle.tscn")

var current_view: Node = null

func _ready() -> void:
	if (GlobalVariables.battleState == GlobalVariables.BattleStates.IN_BATTLE 
	or GlobalVariables.battleState == GlobalVariables.BattleStates.AWAITING_EXIT):
		enter_battle()
	else:
		var levels : Array[level]
		levels.append(level.new(0))
		levels.append(level.new(1))
		levels.append(level.new(1))
		levels.append(level.new(2))
		levels.append(level.new(2))
		levels.append(level.new(3))
		levels.append(level.new(3))
		levels.append(level.new(3))
		levels.append(level.new(4))
		levels.append(level.new(5))
		levels.append(level.new(6))
		
		var map = campaign_map.new(levels)
		draw_map(map)

func show_level_select() -> void:
	_swap_to(level_select_scene)

func enter_battle() -> void:
	_swap_to(battle_area_scene)

func exit_battle() -> void:
	_swap_to(level_select_scene)

func _swap_to(scene_res: PackedScene) -> void:
	if current_view and current_view.get_parent():
		current_view.queue_free()
	current_view = scene_res.instantiate()
	content.add_child(current_view)
	if current_view.has_signal("request_start_signal"):
		current_view.request_start_signal.connect(_on_start_battle_request)
	if current_view.has_signal("request_exit_signal"):
		current_view.request_exit_signal.connect(_on_exit_battle_request)

func draw_map(map : campaign_map):
	var height = get_viewport_rect().size.y
	var width = get_viewport_rect().size.x
	var depths = map.get_depth_count()
	var layers = len(depths)
	var display_height = height*0.8
	var display_width = width*0.8
	var last_depth = -1
	var depth_count = 0
	var control = $CanvasLayer/ScrollContainer/Control
	var levels = map.levels
	var max_height = height
	levels.reverse()
	for lvl in levels:
		if lvl.depth == last_depth:
			depth_count+=1
		else:
			last_depth = lvl.depth
			depth_count = 0
		lvl.y = (display_height/4)*(layers-lvl.depth)
		max_height = max(max_height,lvl.y)
		if depths[lvl.depth] == 1:
			lvl.x = width/2
		else:
			lvl.x = ((display_width/(depths[lvl.depth]-1))*depth_count)+width*0.1
		
		var level_button = TextureButton.new()
		level_button.texture_normal = ResourceLoader.load("res://assets/battlemap/normal_button.png")
		level_button.texture_hover = ResourceLoader.load("res://assets/battlemap/hovered_button.png")
		level_button.texture_pressed = ResourceLoader.load("res://assets/battlemap/pressed_button.png")
		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(level_button.texture_normal.get_image())
		level_button.texture_click_mask = bitmap
		level_button.set_position(Vector2(lvl.x-50,lvl.y-50))
		level_button.scale = Vector2(0.5,0.5)
		level_button.pressed.connect(_on_start_battle_request)
		control.add_child(level_button)
	for path in map.paths:
		var line = Line2D.new()
		line.add_point(Vector2(path.start.x,path.start.y))
		line.add_point(Vector2(path.end.x,path.end.y))
		line.z_index = -1
		control.add_child(line)
	
	control.custom_minimum_size = Vector2(0,max_height+300)
	$CanvasLayer/ScrollContainer.set_deferred("scroll_vertical", $CanvasLayer/ScrollContainer.get_v_scroll_bar().max_value)
func _on_start_battle_request() -> void:
	enter_battle()

func _on_exit_battle_request() -> void:
	exit_battle()
