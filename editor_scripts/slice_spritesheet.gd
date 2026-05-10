@tool
extends Node
class_name SliceSpritesheet 
## Editor Script for automating slicing spritesheets into textures.
##
## [HOW TO USE]: [br]
## 1. Create a temporary 'Node' object in any scene. [br]
## 2. Attach this script to the newly created 'Node' object. [br]
## 3. Settings > set what spreadsheet to slice, sizes and output directory. [br]
## 4. Controls > click 'Run Slice' once (checkmark won't appear, this is normal) to run script.
## Resulting AtlasTexture resource files should now be in 'output_directory'.

@export_group("Settings")
@export var spritesheet: Texture2D
@export var sprite_size: Vector2i = Vector2i(16, 24)
@export_dir var output_directory: String = "res://output/"

@export_group("Controls")
@export var run_slice: bool = false:
	set(val):
		if val: 
			_execute_slice()
			run_slice = false

func _ready():
	printerr("REMOVE EDITOR SCRIPT FROM %s! Should not be attached at runtime!" % [self.get_path()])

func _execute_slice():
	if not spritesheet:
		printerr("No spritesheet assigned!")
		return
		
	if not DirAccess.dir_exists_absolute(output_directory):
		DirAccess.make_dir_recursive_absolute(output_directory)
		
	var columns = spritesheet.get_width() / sprite_size.x
	var rows = spritesheet.get_height() / sprite_size.y
	
	print("Slicing: %d x %d sprites from %s..." % [columns, rows, spritesheet.resource_path])
	
	for y in range(rows):
		for x in range(columns):
			var atlas = AtlasTexture.new()
			atlas.atlas = spritesheet
			atlas.region = Rect2(Vector2(x * sprite_size.x, y * sprite_size.y), sprite_size)
			
			var sheet_name = spritesheet.resource_path.get_file().get_basename()
			var file_path = output_directory.path_join("%s_%d_%d.tres" % [sheet_name, x, y])
			
			ResourceSaver.save(atlas, file_path)
			
	print("Successfully saved to: ", output_directory)
