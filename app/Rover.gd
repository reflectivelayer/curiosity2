extends VehicleBody
signal onMastRotated(angle)
signal onRoverRotated(angle)

var MASTCAM_HEAD_SPEED = 0.3
var SPEED_LIMIT = 0.001
var ANGULAR_SPEED_LIMIT = 0.2
var DRIVE_FORCE = 500
var BRAKE_FORCE = 30
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
var _leftFrontWheel:VehicleWheel
var _rightFrontWheel:VehicleWheel
var _leftRearWheel:VehicleWheel
var _rightRearWheel:VehicleWheel
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
var _previousRotation:Vector3
var _roverLocked:bool  = false

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
	onCameraSelected("hazCamFront")
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
		if _mastCam.rotation.x-MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier>-1.51844:
			_mastCam.rotate_x(-MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
	elif _moveMastCamDown:
		if _mastCam.rotation.x+MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier<1.24:
			_mastCam.rotate_x(MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
	elif _moveMastCamLeft:
		if _mastCamBase.rotation.y+MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier<3:
			_mastCamBase.rotate_y(MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
			_updateMastAngle()
			emit_signal("onMastRotated",_mastAngle+_roverAngle)	
	elif _moveMastCamRight:
		if _mastCamBase.rotation.y+MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier>-3:
			_mastCamBase.rotate_y(-MASTCAM_HEAD_SPEED*delta*_camSpeedMultiplier)
			_updateMastAngle()
			emit_signal("onMastRotated",_mastAngle+_roverAngle)		
	elif _turnLeft:
		_turnRoverLeft()
		_updateRoverAngle()
		emit_signal("onRoverRotated",_roverAngle)
		_updateMastAngle()
		emit_signal("onMastRotated",_roverAngle+_mastAngle)		
	elif _turnRight:
		_turnRoverRight()
		_updateRoverAngle()
		emit_signal("onRoverRotated",_roverAngle)
		_updateMastAngle()
		emit_signal("onMastRotated",_roverAngle+_mastAngle)	
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
			var cam = $MastCam/BaseAxis/Base/CamHead/Mastcam_34
			if cam == _selectedCam:
				_selectedCam = $MastCam/BaseAxis/Base/CamHead/Mastcam_100
				$MastCam/BaseAxis/Base/CamHead/Mastcam_34.current = false
				$Arm.speedMultiplier = 0.1
				_speedMultiplier = 0.1
				_camSpeedMultiplier = 0.2
			else:
				_selectedCam = cam
				$MastCam/BaseAxis/Base/CamHead/Mastcam_100.current = false
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
			_selectedCam = $MastCam/BaseAxis/Base/CamHead/Navcam
			_selectedCam.current = true
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamFront.current = false
			$HazCamRear.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_34.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_100.current = false
		"MAHLI":
			_camLable.text = "MAHLI"			
			$Desaturator.visible = false
			$MastCam/BaseAxis/Base/CamHead/Navcam.current = false
			_selectedCam = $Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI
			_selectedCam.current = true
			$HazCamFront.current = false
			$HazCamRear.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_34.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_100.current = false
		"hazCamFront":
			_camLable.text = "Hazcam(front)"			
			$Desaturator.visible = true
			_selectedCam = $HazCamFront
			_selectedCam.current = true
			$MastCam/BaseAxis/Base/CamHead/Navcam.current = false
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamRear.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_34.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_100.current = false
		"hazCamRear":
			_camLable.text = "Hazcam(rear)"
			$Desaturator.visible = true
			$HazCamFront.current = false
			_selectedCam = $HazCamRear
			_selectedCam.current = true	
			$MastCam/BaseAxis/Base/CamHead/Navcam.current = false
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_34.current = false
			$MastCam/BaseAxis/Base/CamHead/Mastcam_100.current = false			

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
				_stopped = false
			else:
				_driveStop()
		"right":
			_turnRight = isOn
			if isOn:
				_stopped = false
			else:
				_driveStop()
				

func _driveForward():
	lockRoverInPlace(false)		
	_setWheelsforStraight()
	_releaseBrakes()
	_driveWheels(DRIVE_FORCE)
	_driveDirection = 1
	
func _driveBackward():
	lockRoverInPlace(false)	
	_setWheelsforStraight()
	_releaseBrakes()
	_driveWheels(-DRIVE_FORCE)
	_driveDirection = -1	

func _driveStop():
	_brakeAllWheels()
	_setWheelsforStraight()
	_driveDirection = 0
	
func _setWheelsforStraight():
	_leftFrontWheel.steering = 0
	_rightFrontWheel.steering = 0
	_leftRearWheel.steering = 0
	_rightRearWheel.steering = 0
	_rightFrontSuspension.rotation_degrees.y = 180
	_leftFrontSuspension.rotation_degrees.y = 0
	_rightRearSuspension.rotation_degrees.y = 180
	_leftRearSuspension.rotation_degrees.y = 0
	
func _turnPosition():
	_leftFrontWheel.steering = -45
	_rightFrontWheel.steering = 45
	_leftRearWheel.steering = 45
	_rightRearWheel.steering = -45
	_rightFrontSuspension.rotation_degrees.y = 225
	_leftFrontSuspension.rotation_degrees.y = -45
	_rightRearSuspension.rotation_degrees.y = -225
	_leftRearSuspension.rotation_degrees.y = 45

func _updateSpeedControl():
	if _speed>SPEED_LIMIT:
		engine_force = 0
		if brake == 0: brake = 10
	elif _driveDirection!=0 && _speed<SPEED_LIMIT:
		if _driveDirection>=1:
			_driveForward()
		else:
			_driveBackward()
	if abs(angular_velocity.y)>ANGULAR_SPEED_LIMIT:
		if _turnLeft:
			_driveWheelsTurn(-DRIVE_FORCE/50)
		else:
			_driveWheelsTurn(DRIVE_FORCE/50)
	elif(_turnLeft || _turnRight) && abs(angular_velocity.y)<ANGULAR_SPEED_LIMIT:
		if _turnLeft:
			_driveWheelsTurn(-DRIVE_FORCE/20)
		else:
			_driveWheelsTurn(DRIVE_FORCE/20)
	if _driveDirection==0 && !_turnLeft && !_turnRight && !_roverLocked && _speed < 0.0001:
		lockRoverInPlace(true)

func onZoomChanged(value):
	print(value)

func _brakeAllWheels():
	_leftFrontWheel.brake = BRAKE_FORCE
	_rightFrontWheel.brake = BRAKE_FORCE
	_leftRearWheel.brake = BRAKE_FORCE
	_rightRearWheel.brake = BRAKE_FORCE
	
func _releaseBrakes():
	_leftFrontWheel.brake = 0
	_rightFrontWheel.brake = 0
	_leftRearWheel.brake = 0
	_rightRearWheel.brake = 0

func _driveWheels(force:float):
	_leftFrontWheel.engine_force = force
	_rightFrontWheel.engine_force = force
	_leftRearWheel.engine_force = force
	_rightRearWheel.engine_force = force

func _driveWheelsTurn(force:float):
	_leftFrontWheel.engine_force = force
	_rightFrontWheel.engine_force = -force
	_leftRearWheel.engine_force = force
	_rightRearWheel.engine_force = -force	

func _turnRoverLeft():
	lockRoverInPlace(false)	
	linear_velocity =Vector3()
	_turnPosition()
	_driveWheelsTurn(-DRIVE_FORCE/20)
	
func _turnRoverRight():
	lockRoverInPlace(false)
	linear_velocity =Vector3()	
	_turnPosition()
	_driveWheelsTurn(DRIVE_FORCE/20)

func lockRoverInPlace(lock:bool):
	axis_lock_linear_x = lock
	axis_lock_linear_y = lock
	axis_lock_linear_z = lock
	axis_lock_angular_x = lock
	axis_lock_angular_y = lock
	axis_lock_angular_z = lock
	_roverLocked = lock
