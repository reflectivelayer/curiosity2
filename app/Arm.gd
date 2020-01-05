#Default Arm position
#Arm (0.469009, 1.03303, 1.11285)
#Arm (-0, -1.686564, 0)
#Lower (0.000008, -0.164129, 0.168373)
#Lower (-0.261799, 0.166732, 0)
#Upper (0.060753, -0.005095, 0.820141)
#Upper (-1.27409, -0.029269, 0)
#InstrumentBase (-0.188538, 0.792168, -0.000365)
#InstrumentBase (-1.535892, 3.141593, 0)
#Instrument (0.060135, 0.133438, 0.14212)
#Instrument (-0, 2.426008, 0)


extends MeshInstance

var ARM_SPEED = 0.3
var INSTRUMENT_SPEED = 0.4
var _ArmUI
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
var _armLower:MeshInstance
var _armUpper:MeshInstance
var _armInstrumentBase:MeshInstance
var _armInstrument:MeshInstance
var _instrumentsCollider
var speedMultiplier = 1
var _section
var _direction
var _isOn
var _delta
var _collisionUpper
var _raycastUpper:RayCast
var _collisionLower
var _raycastLower:RayCast
var _collisionIncrement = PI/4
var _armParked = false
var _isPreParking = false
var _armFinalPosition = []
var _parkTime = 0
var _parkRotationArm:Transform
var _parkRotationLower:Transform
var _parkRotationUpper:Transform
var _parkRotationInsBase:Transform
var _parkRotationIns:Transform

var _armPreParkTransform:Transform
var _lowerPreParkTransform:Transform
var _upperPreParkTransform:Transform
var _insBasePreParkTransform:Transform
var _insPreParkTransform:Transform
var _drillManager:DrillManager

func _ready():
	_armLower = $Lower
	_armUpper = $Lower/Upper
	_armInstrumentBase = $Lower/Upper/InstrumentBase
	_armInstrument = $Lower/Upper/InstrumentBase/Instruments
	_instrumentsCollider = $Lower/Upper/InstrumentBase/Instruments/RayCast
	_collisionUpper = $Lower/Upper/Collision
	_raycastUpper = $Lower/Upper/Collision/RayCast
	_collisionLower = $Lower/Collision
	_raycastLower = $Lower/Collision/RayCast
	
	var drill = $Lower/Upper/InstrumentBase/Instruments/Drill
	var drillUI = $"../../Control/DrillRect/Drill"
	var anim:Animation = $Animator.get_animation("PreDrill")
	var drillBit = $Lower/Upper/InstrumentBase/Instruments/Drill/DrillBit
	_drillManager = DrillManager.new(drill,drillUI,drillBit,anim,$Animator)
	
	_drillManager.connect("onStopArm",self,"_onStopArm")
		
	_ArmUI = $"../../Control/ArmRect/Arm"
	_ArmUI.connect("armMovement",self,"onArmMovement")

	#_setDefaultPosition()
	_saveArmDistination()
	_armPreParkTransform  = Transform(transform.basis)
	_lowerPreParkTransform  = Transform($Lower.transform.basis)
	_upperPreParkTransform  = Transform($Lower/Upper.transform.basis)
	_insBasePreParkTransform  = Transform($Lower/Upper/InstrumentBase.transform.basis)
	_insPreParkTransform  = Transform($Lower/Upper/InstrumentBase/Instruments.transform.basis)

		
func printArmDefaultPosition():
	print(translation)
	print(rotation)
	print($Lower.translation)
	print($Lower.rotation)
	print($Lower/Upper.translation)
	print($Lower/Upper.rotation)
	print($Lower/Upper/InstrumentBase.translation)
	print($Lower/Upper/InstrumentBase.rotation)
	print($Lower/Upper/InstrumentBase/Instruments.translation)
	print($Lower/Upper/InstrumentBase/Instruments.rotation)		

func _setDefaultPosition():
	translation = Vector3(0.469009, 1.03303, 1.11285)
	rotation = Vector3(-0, -1.686564, 0)
	$Lower.translation = Vector3(0.000008, -0.164129, 0.168373)
	$Lower.rotation = Vector3(-0.261799, 0.166732, 0)
	$Lower/Upper.translation = Vector3(0.060753, -0.005095, 0.820141)
	$Lower/Upper.rotation = Vector3(-1.27409, -0.029269, 0)
	$Lower/Upper/InstrumentBase.translation = Vector3(-0.188538, 0.792168, -0.000365)
	$Lower/Upper/InstrumentBase.rotation = Vector3(-1.535892, 3.141593, 0)
	$Lower/Upper/InstrumentBase/Instruments.translation = Vector3(0.060135, 0.133438, 0.14212)
	$Lower/Upper/InstrumentBase/Instruments.rotation = Vector3(-0, 2.426008, 0)
	

func _process(delta):
	_delta = delta
	if _moveArmBaseLeft:
		rotate_y(-ARM_SPEED*delta*speedMultiplier)
	elif _moveArmBaseRight:
		rotate_y(ARM_SPEED*delta*speedMultiplier)
	elif _moveArmLowerUp:
		_armLower.rotate_x(-ARM_SPEED*delta*speedMultiplier)
		_armUpper.rotate_x(ARM_SPEED*delta*speedMultiplier)
	elif _moveArmLowerDown:
		_armLower.rotate_x(ARM_SPEED*delta*speedMultiplier)
		_armUpper.rotate_x(-ARM_SPEED*delta*speedMultiplier)	
	elif _moveArmUpperUp:
		_armUpper.rotate_x(ARM_SPEED*delta*speedMultiplier)
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta*speedMultiplier)
	elif _moveArmUpperDown:
		_armUpper.rotate_x(-ARM_SPEED*delta*speedMultiplier)
		_armInstrumentBase.rotate_x(ARM_SPEED*delta*speedMultiplier)	
	elif _moveArmInstrumentBaseUp:
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta*speedMultiplier)
	elif _moveArmInstrumentBaseDown:
		_armInstrumentBase.rotate_x(ARM_SPEED*delta*speedMultiplier)
	elif _moveArmInstrumentLeft:
		_armInstrument.rotate_y(-INSTRUMENT_SPEED*delta)
	elif _moveArmInstrumentRight:
		_armInstrument.rotate_y(INSTRUMENT_SPEED*delta)
	if _checkCollision():
		_stopArm()
	_drillManager.update()
	if _isPreParking:
		_updatePrePark()


func _onStopArm():
	_stopArm()
	
func onArmMovement(section, direction,isOn):
	_section = section
	_direction = direction
	_isOn = isOn
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
		"deployment":
			if _armParked:
				 deployArm()
			else:
				_preParkArm()
		
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
	bounceBack()	


func _updatePrePark():
	_parkTime+=0.01
	transform.basis = slerp(_parkRotationArm,_armPreParkTransform,_parkTime)
	$Lower.transform.basis = slerp(_parkRotationLower,_lowerPreParkTransform,_parkTime)
	$Lower/Upper.transform.basis = slerp(_parkRotationUpper,_upperPreParkTransform,_parkTime)
	$Lower/Upper/InstrumentBase.transform.basis = slerp(_parkRotationInsBase,_insBasePreParkTransform,_parkTime)
	$Lower/Upper/InstrumentBase/Instruments.transform.basis = slerp(_parkRotationIns,_insPreParkTransform,_parkTime)

	if _parkTime >= 1: 
		_parkTime = 0
		_isPreParking = false
		parkArm()
		
func deployArm():
		$Animator.play("ExtendArm")
		_armParked = false
		
func _preParkArm():
	_isPreParking = true
	_parkRotationArm = Transform(transform.basis)
	_parkRotationLower = Transform($Lower.transform.basis)	
	_parkRotationUpper = Transform($Lower/Upper.transform.basis)
	_parkRotationInsBase = Transform($Lower/Upper/InstrumentBase.transform.basis)
	_parkRotationIns = Transform($Lower/Upper/InstrumentBase/Instruments.transform.basis)	

func slerp(t1:Transform,t2:Transform,ratio:float)->Basis:
	var a = Quat(t1.basis)
	var b = Quat(t2.basis)
	var c = a.slerpni(b,ratio)
	return Basis(c)


	#if $Lower/Upper.rotation_degrees.x<0: $Lower/Upper.rotation_degrees.x+=360 
func parkArm():
	$Animator.play_backwards("ExtendArm")
	_armParked = true
			
func bounceBack():
	if _isOn:
		print("bounce")
		match _section:
			"base":
				match _direction:
					"left":
						rotate_y(ARM_SPEED*_delta*speedMultiplier*2)
					"right":
						rotate_y(-ARM_SPEED*_delta*speedMultiplier*2)
			"lower":
				match _direction:
					"left":
						_armLower.rotate_x(ARM_SPEED*_delta*speedMultiplier*2)
						_armUpper.rotate_x(-ARM_SPEED*_delta*speedMultiplier*2)
					"right":
						_armLower.rotate_x(-ARM_SPEED*_delta*speedMultiplier*2)
						_armUpper.rotate_x(ARM_SPEED*_delta*speedMultiplier*2)
			"upper":
				match _direction:
					"left":
						_armUpper.rotate_x(-ARM_SPEED*_delta*speedMultiplier*2)
						_armInstrumentBase.rotate_x(ARM_SPEED*_delta*speedMultiplier*2)
					"right":
						_armUpper.rotate_x(ARM_SPEED*_delta*speedMultiplier*2)
						_armInstrumentBase.rotate_x(-ARM_SPEED*_delta*speedMultiplier*2)
			"hinge":
				match _direction:
					"left":
						_armInstrumentBase.rotate_x(ARM_SPEED*_delta*speedMultiplier)
					"right":
						_armInstrumentBase.rotate_x(-ARM_SPEED*_delta*speedMultiplier)
			"tools":
				match _direction:
					"left":
						_armInstrument.rotate_y(ARM_SPEED*_delta*speedMultiplier)
					"right":
						_armInstrument.rotate_y(-ARM_SPEED*_delta*speedMultiplier)

func _checkCollision()->bool:
	_collisionUpper.rotate_y(_collisionIncrement)
	_collisionLower.rotate_z(_collisionIncrement)
	_instrumentsCollider.rotate_y(_collisionIncrement)
	return _raycastUpper.is_colliding() || _raycastLower.is_colliding() || _instrumentsCollider.is_colliding()


func _saveArmDistination():
	var extendArm_anim = $Animator.get_animation("ExtendArm")
	var trackIndex = extendArm_anim.find_track(".:rotation_degrees")
	_armFinalPosition.append(extendArm_anim.track_get_key_value(trackIndex, 5))
	trackIndex = extendArm_anim.find_track("Lower:rotation_degrees")
	_armFinalPosition.append(extendArm_anim.track_get_key_value(trackIndex, 5))
	trackIndex = extendArm_anim.find_track("Lower/Upper:rotation_degrees")
	_armFinalPosition.append(extendArm_anim.track_get_key_value(trackIndex, 5))	
	trackIndex = extendArm_anim.find_track("Lower/Upper/InstrumentBase:rotation_degrees")
	_armFinalPosition.append(extendArm_anim.track_get_key_value(trackIndex, 5))
	trackIndex = extendArm_anim.find_track("Lower/Upper/InstrumentBase/Instruments:rotation_degrees")
	_armFinalPosition.append(extendArm_anim.track_get_key_value(trackIndex, 5))

func _loadArmDestination():
	var extendArm_anim = $Animator.get_animation("ExtendArm")
	var trackIndex = extendArm_anim.find_track(".:rotation_degrees")
	extendArm_anim.track_set_key_value(trackIndex, 5, _armFinalPosition[0])
	trackIndex = extendArm_anim.find_track("Lower:rotation_degrees")
	extendArm_anim.track_set_key_value(trackIndex, 5,_armFinalPosition[1])
	trackIndex = extendArm_anim.find_track("Lower/Upper:rotation_degrees")
	extendArm_anim.track_set_key_value(trackIndex, 5,_armFinalPosition[2])	
	trackIndex = extendArm_anim.find_track("Lower/Upper/InstrumentBase:rotation_degrees")
	extendArm_anim.track_set_key_value(trackIndex, 5, _armFinalPosition[3])	
	trackIndex = extendArm_anim.find_track("Lower/Upper/InstrumentBase/Instruments:rotation_degrees")
	extendArm_anim.track_set_key_value(trackIndex, 5,_armFinalPosition[4])	
	
