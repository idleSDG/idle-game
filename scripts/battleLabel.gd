extends Label

var time

func _init():
	time = 0
	
func _process(_delta):
	text = str(time)

func _on_timer_timeout() -> void:
	time+=1
