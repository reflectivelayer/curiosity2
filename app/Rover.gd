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
var _leftFrontWheel
var _rightFrontWheel
var _leftRearWheel
var _rightRearWheel
var _leftFrontSuspension
var _rightFrontSuspension
var _leftRearSuspension
var _rightRearSuspension

func _ready():
	_mastCam = $MastCam/Base/CamHead
	_mastCamBase = $MastCam/Base
	_armBase = $Arm
	_armLower = $Arm/Lower
	_armUpper = $Arm/Lower/Upper
	_armInstrumentBase = $Arm/Lower/Upper/InstrumentBase
	_armInstrument = $Arm/Lower/Upper/InstrumentBase/Instruments
	_leftFrontWheel = $LeftFront
	_rightFrontWheel = $RightFront
	_leftRearWheel = $LeftRear
	_rightRearWheel = $RightRear
	_leftFrontSuspension = $LeftFrontSuspension
	_rightFrontSuspension = $RightFrontSuspension
	_leftRearSuspension = $LeftRearSuspension
	_rightRearSuspension = $RightRearSuspension
	
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
		_armBase.rotate_y(-ARM_SPEED*delta)
	elif _moveArmBaseRight:
		_armBase.rotate_y(ARM_SPEED*delta)
	elif _moveArmLowerUp:
		_armLower.rotate_x(-ARM_SPEED*delta)
		_armUpper.rotate_x(ARM_SPEED*delta)
	elif _moveArmLowerDown:
		_armLower.rotate_x(ARM_SPEED*delta)
		_armUpper.rotate_x(-ARM_SPEED*delta)	
	elif _moveArmUpperUp:
		_armUpper.rotate_x(ARM_SPEED*delta)
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta)		
	elif _moveArmUpperDown:
		_armUpper.rotate_x(-ARM_SPEED*delta)
		_armInstrumentBase.rotate_x(ARM_SPEED*delta)		
	elif _moveArmInstrumentBaseUp:
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta)
	elif _moveArmInstrumentBaseDown:
		_armInstrumentBase.rotate_x(ARM_SPEED*delta)
	elif _moveArmInstrumentLeft:
		_armInstrument.rotate_y(-ARM_SPEED*delta)
	elif _moveArmInstrumentRight:
		_armInstrument.rotate_y(ARM_SPEED*delta)
	elif _turnLeft:
		add_torque (Vector3(0,2000,0))
		_turnPosition()
		pass
	elif _turnRight:
		add_torque (Vector3(0,-2000,0))
		_turnPosition()		
		pass
		
func onPowerToggle():
	power = !power
	if power:
		$MastCam/MastStartUp.play_backwards("MastStartUp")
	else:
		$MastCam/MastStartUp.play("MastStartUp")

	
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
			if isOn:
				brake = 0
			else:
				brake = 10
				_setSuspensionStraight()
		"right":
			_turnRight = isOn
			if isOn:
				brake = 0
			else:
				brake = 10
				_setSuspensionStraight()
				

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
	engine_force = 500
	
func _driveBackward():
	_setWheelsforStraight()
	brake =0.0	
	engine_force = -500

func _driveStop():
	engine_force=0
	brake = 10

	
func _setWheelsforStraight():
	$RightFront.rotation_degrees.y = 0
	$RightRear.rotation_degrees.y = 0
	$LeftFront.rotation_degrees.y = 0
	$LeftRear.rotation_degrees.y = 0

func _setSuspensionStraight():
	_rightFrontSuspension.rotation_degrees.y = 0
	_leftFrontSuspension.rotation_degrees.y = 0
	_rightRearSuspension.rotation_degrees.y = 0
	_leftRearSuspension.rotation_degrees.y = 0
	
func _turnPosition():
	_rightFrontWheel.rotation_degrees.y = 45
	_leftFrontWheel.rotation_degrees.y = -45
	_rightRearWheel.rotation_degrees.y = -45
	_leftRearWheel.rotation_degrees.y = 45
	_rightFrontSuspension.rotation_degrees.y = 45
	_leftFrontSuspension.rotation_degrees.y = -45
	_rightRearSuspension.rotation_degrees.y = -45
	_leftRearSuspension.rotation_degrees.y = 45		