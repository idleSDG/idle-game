extends Label

func _process(_delta):
	text = str(StepsProgress.dailySteps + StepsProgress.sensorSteps) 
