extends Node2D

@onready var content = $CanvasLayer

var battle_area_scene := preload("res://scenes/battle_area.tscn")
var level_select_scene := preload("res://scenes/battle.tscn")

var beaten_button = preload("res://assets/battlemap/beaten_button.png")
var pressed_button = preload(("res://assets/battlemap/pressed_button.png"))
var hovered_button = preload(("res://assets/battlemap/hovered_button.png"))
var normal_button = preload(("res://assets/battlemap/normal_button.png"))

var current_view: Node = null
var maps : Array[campaign_map]
var current_map : String

func _ready() -> void:
	if (GlobalVariables.battleState == GlobalVariables.BattleStates.IN_BATTLE 
	or GlobalVariables.battleState == GlobalVariables.BattleStates.AWAITING_EXIT):
		enter_battle()
	else:
		if GlobalVariables.campaigns.is_empty():
			GlobalVariables.init_new_battle_save()
		maps = GlobalVariables.campaigns
		current_map = GlobalVariables.current_campaign
		draw_map(maps.filter(func(x): return x.name == current_map).front())
		for map in maps:
			var button = Button.new()
			button.text = map.name
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			$CanvasLayer/CampaignButtonContainer.add_child(button)
			button.pressed.connect(_on_map_changed.bind(map))
		_update_campaign_selection_visuals()
		
func _update_campaign_selection_visuals():
	var buttons = $CanvasLayer/CampaignButtonContainer.get_children()
	for button in buttons:
		var is_active : bool = button.text == current_map
		button.add_theme_font_size_override("font_size", 60 if is_active else 32)
		button.add_theme_color_override("font_color", Color(0.3, 0.8, 1) if is_active else Color(1, 1, 1))

func _on_map_changed(map : campaign_map):
	GlobalVariables.current_campaign = map.name
	current_map = map.name
	draw_map(map)
	_update_campaign_selection_visuals()

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
	var control = $CanvasLayer/ScrollContainer/Control
	for n in control.get_children():
		control.remove_child(n)
		n.queue_free() 
	var height = get_viewport_rect().size.y
	var width = get_viewport_rect().size.x
	var depths = map.get_depth_count()
	var layers = len(depths)
	var display_height = height*0.8
	var display_width = width*0.8
	var last_depth = -1
	var depth_count = 0
	var levels = map.levels
	var max_height = height
	var highest_level = map.find_highest_beaten()
	$CanvasLayer/CampaignBackgroundColor.color = Color.html(map.background_color)
	$CanvasLayer/CampaignBackgroundColor.z_index = -4
	$CanvasLayer/CampaignBackgroundImage.texture = ResourceLoader.load(map.background_image)
	$CanvasLayer/CampaignBackgroundImage.z_index = -3
	$CanvasLayer/CampaignBackgroundImage.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED
	$CanvasLayer/CampaignButtonContainer.z_index = 0
	$CanvasLayer/ScrollContainer.z_index = -1
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
		level_button.texture_normal = normal_button
		level_button.texture_hover = hovered_button
		level_button.texture_pressed = pressed_button
		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(level_button.texture_normal.get_image())
		level_button.texture_click_mask = bitmap
		level_button.set_position(Vector2(lvl.x-50,lvl.y-50))
		level_button.scale = Vector2(0.5,0.5)
		level_button.pressed.connect(_on_start_battle_request.bind(lvl))
		if highest_level == null:
			if lvl.depth != 0:
				level_button.disabled = true
		
		elif lvl.depth != highest_level.depth+1:
			level_button.disabled = true
			if lvl.beaten:
				level_button.texture_normal = beaten_button
		level_button.z_index = 0
		control.add_child(level_button)
	for path in map.paths:
		var line = Line2D.new()
		line.add_point(Vector2(path.start.x,path.start.y))
		line.add_point(Vector2(path.end.x,path.end.y))
		line.z_index = -1
		control.add_child(line)
	
	control.custom_minimum_size = Vector2(0,max_height+300)
	if highest_level != null:
		call_deferred("_scroll_to_bottom",highest_level.y-height/2)
	else:
		call_deferred("_scroll_to_bottom")

func _scroll_to_bottom(max_scroll = INF) -> void:
	var scroll = $CanvasLayer/ScrollContainer
	var scroll_ammount = min(scroll.get_v_scroll_bar().max_value,max_scroll)
	scroll.scroll_vertical = scroll_ammount

func _on_start_battle_request(level : battle_level) -> void:
	for node in $CanvasLayer/ScrollContainer/Control.get_children():
		node.visible = false
	
	GlobalVariables.current_battle_level = level
	enter_battle()

func _on_exit_battle_request() -> void:
	exit_battle()
