extends VBoxContainer

var _buttons = []
signal cameraSelected(camera)
signal cameraZoomChanged(zoom)

# Called when the node enters the scene tree for the first time.
func _ready():
	_buttons.append($Panel1)
	_buttons.append($Panel2)
	_buttons.append($Panel3)
	_buttons.append($Panel4)
	_buttons.append($Panel5)	
	setButtonIndex(3)

func _on_Cam_button_up(camera):
	emit_signal("cameraSelected",camera)
	setButtonIndex(nameToIndex(camera))

func _on_ZoomLevel_value_changed(value):
	emit_signal("cameraZoomChanged",value)

func nameToIndex(cam)->int:
	match(cam):
		"navCam": return 0
		"mastCam": return 1
		"MAHLI": return 2
		"hazCamFront": return 3
		"hazCamRear": return 4
	return 0
	
func setButtonIndex(index):
	var sb 
	for i in range(0,_buttons.size()):
		sb = _buttons[i].get_stylebox("panel", "" )
		if index == i:
			sb.bg_color = Color("#003399")
		else:
			sb.bg_color = Color("#666666")
