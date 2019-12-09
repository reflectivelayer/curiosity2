extends Control

var width:float

# Called when the node enters the scene tree for the first time.
func _ready():
	width = $Compass.get_texture().get_size().x*$Compass.scale.x-7

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func setRoverPointer(angle:float):
	$RoverPointer.position.x = angle/360*width
	
func setMastPointer(angle:float):
	$MastPointer.position.x = angle/360*width
