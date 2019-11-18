extends Spatial

var rover:VehicleBody

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CamCenter.rotate(Vector3(0,1,0),0.01)


