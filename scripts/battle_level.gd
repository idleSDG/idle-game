class_name battle_level

## Depth level inside the campaign
var depth: int = 0
## Positiion inside the levels of the same depth
var position : int = 0
var x : float = 0.0
var y : float = 0.0
## Used to track which levels were beaten inside the map
var beaten : bool = false

func _init(p_depth : int, p_position : int, p_beaten : bool) -> void:
	depth = p_depth
	position = p_position
	beaten = p_beaten
	
func get_save_data() -> Dictionary:
	return { "depth" : depth, 
	"position" : position, 
	"beaten" : beaten}

static func from_save(data : Dictionary) -> battle_level:
	var p_depth = (data["depth"] if data.has("depth") else 0)
	var p_position = (data["position"] if data.has("position") else 0)
	var p_beaten = (data["beaten"] if data.has("beaten") else false)

	return battle_level.new(p_depth,p_position,p_beaten)
