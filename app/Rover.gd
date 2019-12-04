extends VehicleBody

var MASTCAM_HEAD_SPEED = 0.3
var ARM_SPEED = 0.3
var SPEED_LIMIT = 0.001
var DRIVE_FORCE = 1500
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
var _previousPosition:Vector3
var _stopped:bool = false
var _armDeploying = false
var _armRetracting = false
var _armDeployed = false
var _speed
var _driveDirection = 1 #positive is foward negative is backward
var _instrumentCollider
var _camLable
var _drill:MeshInstance
var _selectedCam

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
	_instrumentCollider = $Arm/Lower/Upper/InstrumentBase/Instruments/RayCast/Ray
	_drill = $Arm/Lower/Upper/InstrumentBase/Instruments/Drill
	
	MastUI = get_parent().get_node("Control/MastRect/Mast")
	MastUI.connect("powerToggle",self,"onPowerToggle")
	MastUI.connect("mastMovment",self,"onMastMovement")
	
	ArmUI = get_parent().get_node("Control/ArmRect/Arm")
	ArmUI.connect("cameraDeploy",self,"onCmeraDeploy")
	ArmUI.connect("armMovment",self,"onArmMovement")	
	
	DriveUI = get_parent().get_node("Control/DriveRect/Drive")
	DriveUI.connect("driveMovment",self,"onDriveMovement")

	CamUI = get_parent().get_node("Control/CamSelector")
	CamUI.connect("cameraSelected",self,"onCameraSelected")
	CamUI.connect("cameraZoomChanged",self,"onZoomChanged")
	_camLable = get_parent().get_node("Control/SelectedCam")
	
	_drill.connect("onDrillContact",self,"onDrillContact")
	_driveStop()
	onCameraSelected("navCam")
func _deployArm(delta):
	#var done = 0
	#if _armBase.rotation_degrees.y<0:
	#	_armBase.rotate_y(ARM_SPEED*delta)
	#else: done+=1

	#if _armLower.rotation_degrees.x>-88:
	#	_armLower.rotate_x(-ARM_SPEED*delta)
	#	_armUpper.rotate_x(ARM_SPEED*delta)
	#else: done+=1
			
	#if _armUpper.rotation_degrees.x>0:
	#	_armUpper.rotate_x(ARM_SPEED*delta)
	#	_armInstrumentBase.rotate_x(-ARM_SPEED*delta)
	#else: done+=1

	#if done== 3: 
	_armDeploying = false
	_armDeployed = true
	_drill.engage()

func _retractArm(delta):
	#var done = 0
	#if _armBase.rotation_degrees.y>-88:	
	#	_armBase.rotate_y(-ARM_SPEED*delta)
	#else: done+=1

	#if _armLower.rotation_degrees.x<0:
	#	_armLower.rotate_x(ARM_SPEED*delta)
	#	_armUpper.rotate_x(-ARM_SPEED*delta)
	#else: done+=1
			
	#if _armUpper.rotation_degrees.x>-80:
	#	_armUpper.rotate_x(-ARM_SPEED*delta)
	#	_armInstrumentBase.rotate_x(+ARM_SPEED*delta)
	#else: done+=1
	
	#if done== 3: 
	_armRetracting = false
	_armDeployed = false
	_drill.disengage()
	
func _process(delta):
	_speed = _previousPosition.distance_squared_to(translation)
	if _armDeploying:
		_deployArm(delta)
	if _armRetracting:
		_retractArm(delta)
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
		applyTurnForce(1)
		_turnPosition()
		pass
	elif _turnRight:
		applyTurnForce(-1)
		_turnPosition()	
		pass
	if !_turnLeft && !_turnRight && engine_force==0 && !_stopped && _speed<0.000001:
		_stopped = true
		_lockAxis()
	_previousPosition = translation*1
	_updateSpeedControl()
	#if checkInstumentCollision(): _stopArm()
			
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
	match camera:
		"mastCam":
			_camLable.text = "Mastcam"
			$Desaturator.visible = false
			var cam = $MastCam/Base/CamHead/Mastcam
			if cam == _selectedCam:
				if _selectedCam.fov == 21:
					_selectedCam.fov = 7
				else:
					cam.fov = 21
			else:
				_selectedCam = cam
			_selectedCam.current = true
			$MastCam/Base/CamHead/Navcam.current = false
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamFront.current = false
			$HazCamRear.current = false	
		"navCam":
			_camLable.text = "Navcam"
			$Desaturator.visible = true
			$MastCam/Base/CamHead/Mastcam.current = false
			_selectedCam = $MastCam/Base/CamHead/Navcam
			_selectedCam.current = true
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamFront.current = false
			$HazCamRear.current = false				
		"MAHLI":
			_camLable.text = "MAHLI"			
			$Desaturator.visible = false
			$MastCam/Base/CamHead/Mastcam.current = false
			$MastCam/Base/CamHead/Navcam.current = false
			_selectedCam = $Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI
			_selectedCam.current = true
			$HazCamFront.current = false
			$HazCamRear.current = false
		"hazCamFront":
			_camLable.text = "Hazcam(front)"			
			$Desaturator.visible = true
			_selectedCam = $HazCamFront
			_selectedCam.current = true
			$MastCam/Base/CamHead/Mastcam.current = false
			$MastCam/Base/CamHead/Navcam.current = false
			$Arm/Lower/Upper/InstrumentBase/Instruments/MAHLI.current = false
			$HazCamRear.current = false
		"hazCamRear":
			_camLable.text = "Hazcam(rear)"
			$Desaturator.visible = true
			$HazCamFront.current = false
			$MastCam/Base/CamHead/Mastcam.current = false
			$MastCam/Base/CamHead/Navcam.current = false
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
	var turnForce = 200
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

func _stopArm():
	_moveArmBaseLeft = false
	_moveArmBaseRight = false
	_moveArmLowerUp = false
	_moveArmLowerDown = false
	_moveArmUpperUp = false
	_moveArmUpperDown = false
	_moveArmInstrumentBaseUp = false
	_moveArmInstrumentBaseDown = false
	_moveArmInstrumentLeft = false
	_moveArmInstrumentRight = false	

func _on_Collision_area_entered(area,section):
	print("xxxx")
	_stopArm()

func _on_Collision_body_entered(body,section):
	_stopArm()

func checkInstumentCollision():
	var origin = _instrumentCollider.get_parent()
	origin.rotate_y(PI/4)
	if _instrumentCollider.is_colliding(): return true
	return false
	
func onZoomChanged(value):
	print(value)
	
func onDrillContact(contactA,contactB):
	if contactA>=0.04 || contactB>=0.04:
		_stopArm()
	elif  contactA>=0 && contactB>=0:
		print("STABLE")
	