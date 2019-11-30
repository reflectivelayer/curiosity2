extends VBoxContainer

signal cameraSelected(camera)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Cam_button_up(camera):
	emit_signal("cameraSelected",camera)
