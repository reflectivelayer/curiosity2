extends VehicleBody

var MASTCAM_HEAD_SPEED = 0.003
var UI
var power = false
var _moveMastCamUp = false
var _moveMastCamDown = false
var _moveMastCamLeft = false
var _moveMastCamRight = false
var _mastCam:MeshInstance
var _mastCamBase:MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	_mastCam = $MastCam/Base/CamHead
	_mastCamBase = $MastCam/Base
	UI = get_parent().get_node("Control/PanelContainer")
	UI.connect("powerToggle",self,"onPowerToggle")
	UI.connect("mastMovment",self,"onMovement")

func _process(delta):
	if _moveMastCamUp:
		_mastCam.rotate_x(-MASTCAM_HEAD_SPEED)
	if _moveMastCamDown:
		_mastCam.rotate_x(MASTCAM_HEAD_SPEED)
	if _moveMastCamLeft:
		_mastCamBase.rotate_y(MASTCAM_HEAD_SPEED)
	if _moveMastCamRight:
		_mastCamBase.rotate_y(-MASTCAM_HEAD_SPEED)
		
		
func onPowerToggle():
	if power:
		$MastCam/MastStartUp.play_backwards("MastStartUp")
	else:
		$MastCam/MastStartUp.play("MastStartUp")
	power = !power
	
func onMovement(direction,isOn):
	match direction:
		"up":
			_moveMastCamUp = isOn
		"down":
			_moveMastCamDown = isOn
		"left":
			_moveMastCamLeft = isOn
		"right":
			_moveMastCamRight = isOn


func onMovementDown(isOn):
	_moveMastCamDown = isOn