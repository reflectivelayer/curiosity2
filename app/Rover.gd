extends VehicleBody
signal onMastRotated(angle)
signal onRoverRotated(angle)

var MASTCAM_HEAD_SPEED = 0.3
var SPEED_LIMIT = 0.001
var DRIVE_FORCE = 20
var MastUI
var ArmUI
var DriveUI
var CamUI
var ZoomControl

var power = false
var _moveMastCamUp = false
var _moveMastCamDown = false
var _moveMastCamLeft = false
var _moveMastCamRight = false
var _driveForward = false
var _driveBackward = false
var _turnLeft = false
var _turnRight = false

var _mastCam:MeshInstance
var _mastCamBase:MeshInstance

var _useMAHLI = false
var _leftFrontWheel
var _rightFrontWheel
var _leftRearWheel
var _rightRearWheel
var _leftFrontSuspension
var _rightFrontSuspension
var _leftRearSuspension
var _rightRearSuspension
var _previousPosition:Vector3
var _stopped:bool = false
var _armDeploying = false
var _armRetracting = false
var _armDeployed = false
var _speed
var _driveDirection = 1 #positive is foward negative is backward
var _camLable
var _selectedCam
var _speedMultiplier = 1
var _camSpeedMultiplier = 1
var _mastAngle = 0
var _roverAngle = 0

func _ready():
	_mastCam = $MastCam/BaseAxis/Base/CamHead
	_mastCamBase = $MastCam/BaseAxis/Base

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
	ArmUI.connect("cameraDeploy",self,"onCmeraDeploy")
	
	DriveUI = get_parent().get_node("Control/DriveRect/Drive")
	DriveUI.connect("driveMovment",self,"onDriveMovement")

	CamUI = get_parent().get_node("Control/CamSelector")
	CamUI.connect("cameraSelected",self,"onCameraSelected")
	CamUI.connect("cameraZoomChanged",self,"onZoomChanged")
	_camLable = get_parent().get_node("Control/SelectedCam")
	_driveStop()
	onCameraSelected("navCam")
	_updateMastAngle()
	_updateRoverAngle()

	
func _deployArm(delta):
	_armDeploying = false
	_armDeployed = true

func _retractArm(delta):
	_armRetracting = false
	_armDeployed = false
	
func _process(delta):
	_speed = _previousPosition.distance_squared_to(translation)
	if _armDeploying:
		_deployArm(delta)
	if _armRetracting:
		_retractArm(delta)
	if _moveMastCamUp:
		_mastCam.rotate_x(-MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
	elif _moveMastCamDown:
		_mastCam.rotate_x(MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
	elif _moveMastCamLeft:
		_mastCamBase.rotate_y(MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
		_updateMastAngle()
		emit_signal("onMastRotated",_mastAngle+_roverAngle)	
	elif _moveMastCamRight:
		_mastCamBase.rotate_y(-MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
		_updateMastAngle()
		emit_signal("onMastRotated",_mastAngle+_roverAngle)		
	elif _turnLeft:
		applyTurnForce(1)
		_turnPosition()
		_updateRoverAngle()
		emit_signal("onRoverRotated",_roverAngle)
		_updateMastAngle()
		emit_signal("onMastRotated",_roverAngle+_mastAngle)		
	elif _turnRight:
		applyTurnForce(-1)
		_turnPosition()	
		_updateRoverAngle()
		emit_signal("onRoverRotated",_roverAngle)
		_updateMastAngle()
		emit_signal("onMastRotated",_roverAngle+_mastAngle)	
	if !_turnLeft && !_turnRight && engine_force==0 && !_stopped && _speed<0.000001:
		_stopped = true
		_lockAxis()
	_previousPosition = translation*1
	_updateSpeedControl()
	#if checkInstumentCollision(): _stopArm()

func _updateMastAngle():
	_mastAngle = _mastCamBase.rotation_degrees.y
	if _mastAngle<0:_mastAngle =360+_mastAngle	

func _updateRoverAngle():
	_roverAngle = rotation_degrees.y
	if _roverAngle<0:_roverAngle =360+_roverAngle	
		
func onPowerToggle():
	power = !power
	if power:
		$MastCam/MastStartUp.play_backwards("MastStartUp")
	else:
		$MastCam/MastStartUp.play("MastStartUp")

	
func onCmeraDeploy():
	if _armDeploying || _armDeployed:
		_armRetracting = true
		_armDeploying = false	
	else:
		_armDeploying = true
	
func onCameraSelected(camera):
	$Arm.speedMultiplier = 1
	_speedMultiplier = 1
	_camSpeedMultiplier = 1
	match camera:
		"mastCam":
			_camLable.text = "Mastcam"
			$Desaturator.visible = false
			var cam = $MastCam/BaseAxis/Base/CamHead/Mastcam
			if cam == _selectedCam:
				if _selectedCam.fov == 21:
					_selectedCam.fov = 7
					$Arm.speedMultiplier = 0.1
					_speedMultiplier = 0.1
					_camSpeedMultiplier = 0.2
				else:
					cam.fov = 21
					$Arm.speedMultiplier = 0.2
					_speedMultiplier = 0.2
					_camSpeedMultiplier = 0.4
			else:
				_selectedCam = cam
				$Arm.speedMultiplier = 0.2
				_speedMultiplier = 0.2
				_camSpeedMultiplier = 0.4
			_selectedCam.current = true
			$MastCam/BaseAxis/Base/CamHead/Navcam.current = false
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamFront.current = false
			$HazCamRear.current = false	
		"navCam":
			_camLable.text = "Navcam"
			$Desaturator.visible = true
			$MastCam/BaseAxis/Base/CamHead/Mastcam.current = false
			_selectedCam = $MastCam/BaseAxis/Base/CamHead/Navcam
			_selectedCam.current = true
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamFront.current = false
			$HazCamRear.current = false				
		"MAHLI":
			_camLable.text = "MAHLI"			
			$Desaturator.visible = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam.current = false
			$MastCam/BaseAxis/Base/CamHead/Navcam.current = false
			_selectedCam = $Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI
			_selectedCam.current = true
			$HazCamFront.current = false
			$HazCamRear.current = false
		"hazCamFront":
			_camLable.text = "Hazcam(front)"			
			$Desaturator.visible = true
			_selectedCam = $HazCamFront
			_selectedCam.current = true
			$MastCam/BaseAxis/Base/CamHead/Mastcam.current = false
			$MastCam/BaseAxis/Base/CamHead/Navcam.current = false
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamRear.current = false
		"hazCamRear":
			_camLable.text = "Hazcam(rear)"
			$Desaturator.visible = true
			$HazCamFront.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam.current = false
			$MastCam/BaseAxis/Base/CamHead/Navcam.current = false
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			_selectedCam = $HazCamRear
			_selectedCam.current = true
			

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
				if _stopped:
					_stopped = false
					_unlockAxis()
					_driveForward()
			else:
				_driveStop()
		"down":
			if isOn:
				if _stopped:
					_stopped = false
					_unlockAxis()
					_driveBackward()
			else:
				_driveStop()
		"left":
			_turnLeft = isOn
			if isOn:
				if _stopped:
					brake = 0
					_stopped = false
					_unlockAxis()
			else:
				brake = 100
				_setSuspensionStraight()
		"right":
			_turnRight = isOn
			if isOn:
				if _stopped:
					brake = 0	
					_stopped = false
					_unlockAxis()
			else:
				brake = 100
				_setSuspensionStraight()
				

func _driveForward():
	_setWheelsforStraight()
	brake =0.0
	engine_force = DRIVE_FORCE
	_driveDirection = 1
	
func _driveBackward():
	_setWheelsforStraight()
	brake =0.0	
	engine_force = -DRIVE_FORCE
	_driveDirection = -1	

func _driveStop():
	engine_force=0
	brake = 100
	_driveDirection = 0

	
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
	axis_lock_linear_x = false
	axis_lock_linear_z = false	
	
func _turnPosition():
	_rightFrontWheel.rotation_degrees.y = 45
	_leftFrontWheel.rotation_degrees.y = -45
	_rightRearWheel.rotation_degrees.y = -45
	_leftRearWheel.rotation_degrees.y = 45
	_rightFrontSuspension.rotation_degrees.y = 45
	_leftFrontSuspension.rotation_degrees.y = -45
	_rightRearSuspension.rotation_degrees.y = -45
	_leftRearSuspension.rotation_degrees.y = 45
	axis_lock_linear_x = true
	axis_lock_linear_z = true
	
func applyTurnForce(direction):
	var turnForce = 25
	var torqueVector = Vector3(0,0,100)
	if direction>0:
		add_force( Vector3(turnForce,0,0),torqueVector)
		add_force( Vector3(-turnForce,0,0),-torqueVector)
	else:
		add_force( Vector3(-turnForce,0,0),torqueVector)
		add_force( Vector3(turnForce,0,0),-torqueVector)

func _lockAxis():
	axis_lock_linear_x = true
	axis_lock_linear_z = true
	axis_lock_angular_y = true	
	
func _unlockAxis():
	axis_lock_linear_x = false
	axis_lock_linear_z = false
	axis_lock_angular_y = false
	
func _updateSpeedControl():
	if _speed>SPEED_LIMIT:
		engine_force = 0
		if brake == 0: brake = 10
	elif _driveDirection!=0 && _speed<SPEED_LIMIT:
		if _driveDirection>=1:
			_driveForward()
		else:
			_driveBackward()


func onZoomChanged(value):
	print(value)
	
