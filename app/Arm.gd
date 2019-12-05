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
var _ArmUI
var _Drill:MeshInstance

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
var _DrillUI

func _ready():
	_armLower = $Lower
	_armUpper = $Lower/Upper
	_armInstrumentBase = $Lower/Upper/InstrumentBase
	_armInstrument = $Lower/Upper/InstrumentBase/Instruments
	_instrumentsCollider = $Lower/Upper/InstrumentBase/Instruments/RayCast
	_Drill = $Lower/Upper/InstrumentBase/Instruments/Drill
	_collisionUpper = $Lower/Upper/Collision
	_raycastUpper = $Lower/Upper/Collision/RayCast
	_collisionLower = $Lower/Collision
	_raycastLower = $Lower/Collision/RayCast
	
	_ArmUI = $"../../Control/ArmRect/Arm"
	_ArmUI.connect("armMovement",self,"onArmMovement")
	_DrillUI = $"../../Control/DrillRect/Drill"
	_DrillUI.connect("drillAction",self,"_onDrillAction")	
	_Drill.connect("onDrillContact",self,"onDrillContact")
	_setDefaultPosition()
	

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
		_armInstrument.rotate_y(-ARM_SPEED*delta*speedMultiplier)
	elif _moveArmInstrumentRight:
		_armInstrument.rotate_y(ARM_SPEED*delta*speedMultiplier)
	if _checkCollision():
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

	
func onDrillContact(contactA,contactB):
	if contactA>=0.04 || contactB>=0.04:
		_stopArm()
	elif  contactA>=0 && contactB>=0:
		pass
	_DrillUI.setContactLeft(contactA>=0.01) 
	_DrillUI.setContactRight(contactB>=0.01)
	
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
		
func _onDrillAction(direction,isOn):
	if direction == "down":
		_Drill.lowerDrill(isOn)
	elif direction == "up":
		_Drill.raiseDrill(isOn)	
	elif direction == "activate":
		_Drill.activate(isOn)		