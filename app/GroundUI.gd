extends Control

var _armPanelOpen = false
var _mastPanelOpen = false
var _drivePanelOpen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if _armPanelOpen:
		$PanelSlider.play_backwards("RoboticArmPanel")
	else:
		$ArmRect.raise()
		$PanelSlider.play("RoboticArmPanel")
	_armPanelOpen = !_armPanelOpen		

func _on_Mast_Paneel_pressed():
	if _mastPanelOpen:
		$PanelSlider.play_backwards("MastCamPanel")
	else:
		$PanelSlider.play("MastCamPanel")	
	_mastPanelOpen = !_mastPanelOpen		


func _on_drive_panel_pressed():
	if _drivePanelOpen:
		$PanelSlider.play_backwards("DrivePanel")
	else:
		$PanelSlider.play("DrivePanel")	
	_drivePanelOpen = !_drivePanelOpen		

