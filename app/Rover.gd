extends VehicleBody

var MASTCAM_HEAD_SPEED = 0.3
var ARM_SPEED = 0.3
var MastUI
var ArmUI
var DriveUI
var power = false
var _moveMastCamUp = false
var _moveMastCamDown = false
var _moveMastCamLeft = false
var _moveMastCamRight = false
var _driveForward = false
var _driveBackward = false
var _turnLeft = false
var _turnRight = false
var _moveArmBaseLeft = false
var _moveArmBaseRight = false
var _moveArmLowerUp = false
var _moveArmLowerDown = false
var _moveArmUpperUp = false
var _moveArmUpperDown = false
var _moveArmInstrumentBaseUp = false
var _moveArmInstrumentBaseDown = false
var _moveArmInstrumentLeft = false
var _moveArmInstrumentRight = false
var _mastCam:MeshInstance
var _mastCamBase:MeshInstance
var _armBase:MeshInstance
var _armLower:MeshInstance
var _armUpper:MeshInstance
var _armInstrumentBase:MeshInstance
var _armInstrument:MeshInstance
var _useMAHLI = false

func _ready():
	_mastCam = $MastCam/Base/CamHead
	_mastCamBase = $MastCam/Base
	_armBase = $Arm
	_armLower = $Arm/Lower
	_armUpper = $Arm/Lower/Upper
	_armInstrumentBase = $Arm/Lower/Upper/InstrumentBase
	_armInstrument = $Arm/Lower/Upper/InstrumentBase/Instruments

	MastUI = get_parent().get_node("Control/MastRect/Mast")
	MastUI.connect("powerToggle",self,"onPowerToggle")
	MastUI.connect("mastMovment",self,"onMastMovement")
	
	ArmUI = get_parent().get_node("Control/ArmRect/Arm")
	ArmUI.connect("cameraToggle",self,"onCameraToggle")
	ArmUI.connect("armMovment",self,"onArmMovement")	
	
	DriveUI = get_parent().get_node("Control/DriveRect/Drive")
	DriveUI.connect("driveMovment",self,"onDriveMovement")
		
func _process(delta):
	if _moveMastCamUp:
		_mastCam.rotate_x(-MASTCAM_HEAD_SPEED*delta)
	elif _moveMastCamDown:
		_mastCam.rotate_x(MASTCAM_HEAD_SPEED*delta)
	elif _moveMastCamLeft:
		_mastCamBase.rotate_y(MASTCAM_HEAD_SPEED*delta)
	elif _moveMastCamRight:
		_mastCamBase.rotate_y(-MASTCAM_HEAD_SPEED*delta)
	elif _moveArmBaseLeft:
		_armBase.rotate_y(ARM_SPEED*delta)
	elif _moveArmBaseRight:
		_armBase.rotate_y(-ARM_SPEED*delta)
	elif _moveArmLowerUp:
		_armLower.rotate_x(ARM_SPEED*delta)
		_armUpper.rotate_x(-ARM_SPEED*delta)
	elif _moveArmLowerDown:
		_armLower.rotate_x(-ARM_SPEED*delta)
		_armUpper.rotate_x(ARM_SPEED*delta)	
	elif _moveArmUpperUp:
		_armUpper.rotate_x(ARM_SPEED*delta)
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta)		
	elif _moveArmUpperDown:
		_armUpper.rotate_x(-ARM_SPEED*delta)
		_armInstrumentBase.rotate_x(ARM_SPEED*delta)		
	elif _moveArmInstrumentBaseUp:
		_armInstrumentBase.rotate_x(ARM_SPEED*delta)
	elif _moveArmInstrumentBaseDown:
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta)
	elif _moveArmInstrumentLeft:
		_armInstrument.rotate_y(ARM_SPEED*delta)
	elif _moveArmInstrumentRight:
		_armInstrument.rotate_y(-ARM_SPEED*delta)
	elif _turnLeft:
		rotate_y(0.005)
	elif _turnRight:
		rotate_y(-0.005)
		
func onPowerToggle():
	power = !power
	if power:
		engine_force = 30
		brake = 0		
		#$MastCam/MastStartUp.play_backwards("MastStartUp")
	else:
		engine_force = 0
		brake = 0.8	
		#$MastCam/MastStartUp.play("MastStartUp")

	
func onCameraToggle():
	_useMAHLI = !_useMAHLI
	if _useMAHLI:
		$MastCam/Base/CamHead/Camera.current = false
		$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = true
		
	else:
		$MastCam/Base/CamHead/Camera.current = true
		$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false


func onMastMovement(direction,isOn):
	match direction:
		"up":
			_moveMastCamUp = isOn
		"down":
			_moveMastCamDown = isOn
		"left":
			_moveMastCamLeft = isOn
		"right":
			_moveMastCamRight = isOn

func onDriveMovement(direction,isOn):
	match direction:
		"up":
			if isOn:
				_driveForward()
			else:
				_driveStop()
		"down":
			if isOn:
				_driveBackward()
			else:
				_driveStop()
		"left":
			_turnLeft = isOn
		"right":
			_turnRight = isOn

func onArmMovement(section, direction,isOn):
	match section:
		"base":
			match direction:
				"left":
					_moveArmBaseLeft = isOn
				"right":
					_moveArmBaseRight = isOn
		"lower":
			match direction:
				"left":
					_moveArmLowerUp = isOn
				"right":
					_moveArmLowerDown = isOn
		"upper":
			match direction:
				"left":
					_moveArmUpperUp = isOn
				"right":
					_moveArmUpperDown = isOn
		"hinge":
			match direction:
				"left":
					_moveArmInstrumentBaseUp = isOn
				"right":
					_moveArmInstrumentBaseDown = isOn
		"tools":
			match direction:
				"left":
					_moveArmInstrumentLeft = isOn
				"right":
					_moveArmInstrumentRight = isOn
					
func _driveForward():
	_setWheelsforStraight()
	brake =0.0
	engine_force = 20
	
func _driveBackward():
	_setWheelsforStraight()
	brake =0.0	
	engine_force = -20
	
func _turnLeft():
	_setWheelsforTurn()
	
func _turnRight():
	_setWheelsforTurn()
	
func _driveStop():
	engine_force=0
	brake = 1

func _setWheelsforTurn():
	$RightFront.rotate_y(35)
	$LeftFront.rotation_degrees.y = -35
	$RightRear.rotation_degrees.y = -35
	$LeftRear.rotation_degrees.y = 35
	print("HGF")
	
func _setWheelsforStraight():
	$RightFront.rotation_degrees.y = 0
	$RightRear.rotation_degrees.y = 0
	$LeftFront.rotation_degrees.y = 0
	$LeftRear.rotation_degrees.y = 0
	