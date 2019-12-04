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
var _armBase:MeshInstance
var _armLower:MeshInstance
var _armUpper:MeshInstance
var _armInstrumentBase:MeshInstance
var _armInstrument:MeshInstance
var _instrumentCollider
var _speedMultiplier = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	_armLower = $Lower
	_armUpper = $Lower/Upper
	_armInstrumentBase = $Lower/Upper/InstrumentBase
	_armInstrument = $Lower/Upper/InstrumentBase/Instruments
	_instrumentCollider = $Lower/Upper/InstrumentBase/Instruments/RayCast/Ray
	_Drill = $Lower/Upper/InstrumentBase/Instruments/Drill
	_ArmUI = $"../../Control/ArmRect/Arm"
	_ArmUI.connect("armMovement",self,"onArmMovement")
	_Drill.connect("onDrillContact",self,"onDrillContact")

func _process(delta):
	
	if _moveArmBaseLeft:
		rotate_y(-ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmBaseRight:
		rotate_y(ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmLowerUp:
		_armLower.rotate_x(-ARM_SPEED*delta*_speedMultiplier)
		_armUpper.rotate_x(ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmLowerDown:
		_armLower.rotate_x(ARM_SPEED*delta*_speedMultiplier)
		_armUpper.rotate_x(-ARM_SPEED*delta*_speedMultiplier)	
	elif _moveArmUpperUp:
		_armUpper.rotate_x(ARM_SPEED*delta*_speedMultiplier)
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmUpperDown:
		_armUpper.rotate_x(-ARM_SPEED*delta*_speedMultiplier)
		_armInstrumentBase.rotate_x(ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmInstrumentBaseUp:
		_armInstrumentBase.rotate_x(-ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmInstrumentBaseDown:
		_armInstrumentBase.rotate_x(ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmInstrumentLeft:
		_armInstrument.rotate_y(-ARM_SPEED*delta*_speedMultiplier)
	elif _moveArmInstrumentRight:
		_armInstrument.rotate_y(ARM_SPEED*delta*_speedMultiplier)

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
	
func onDrillContact(contactA,contactB):
	if contactA>=0.04 || contactB>=0.04:
		_stopArm()
	elif  contactA>=0 && contactB>=0:
		print("STABLE")	

	if contactA>=0.01 || contactB>=0.01:
		_speedMultiplier = 0.1
	elif contactA<0.01|| contactB<0.01:
		_speedMultiplier = 1
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