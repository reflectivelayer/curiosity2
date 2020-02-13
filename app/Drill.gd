extends Spatial
class_name Drill

signal onDrillContact(contactA,contactB)
signal onDrillTipContact(target,contactPoint, normal, drillDepth)
signal onDrillParked() 

var MAX_DEPTH = 0.065  # 6.5cm
var rockTarget:Spatial
var spin:int = 0
var direction:int = 0
var _drillDepth = 0
var _movementlRate = 0.02
var _orgZ:float
var _contact_L:RayCast
var _contact_R:RayCast
var _contactDepth_L
var _contactDepth_B
var _contactSense_L:MeshInstance
var _contactSense_R:MeshInstance
var dst_L = 0 
var dst_R = 0 
var _drillBit
var _drillTip:RayCast
var contactPoint = null
var _dig = 0.0
var _pressure = 0


func _ready():
	_contact_L = $"../Contact_L"
	_contact_R = $"../Contact_R"
	_drillBit = $DrillBit
	_drillTip = $DrillBit/Tip
	_contactSense_L = $"../DrillContactSensors_L"
	_contactSense_R = $"../DrillContactSensors_R"
	_orgZ = translation.z
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _drillDepth > MAX_DEPTH && direction == 1:
		_turnDrillOff()
	dst_L = -1
	dst_R = -1
	if direction!=0:	
		var movZ = _movementlRate*direction*delta
		if contactPoint == null:
			if translation.z+movZ>_orgZ:
				translate(Vector3(0,0,movZ))
			else:
				_turnDrillOff()	
				emit_signal("onDrillParked")
		else:
			if direction == 1:
				movZ = rockTarget.drill(translation,_pressure*spin)
				translate(Vector3(0,0,movZ))
			else:
				translate(Vector3(0,0,movZ))
			
	if spin!=0:
		_drillBit.rotate_z(0.2*spin)
	var collider = _contact_L.get_collider()
	if collider!=null:
		dst_L = _contact_L.get_collision_point().distance_to(_contact_L.to_global(_contact_L.cast_to))
	collider = _contact_R.get_collider()
	if collider!=null:
		dst_R = _contact_R.get_collision_point().distance_to(_contact_R.to_global(_contact_R.cast_to))

	if dst_L>=0 || dst_R >=0:
		if dst_L>0: _contactSense_L.translation.z = -dst_L
		if dst_R>0: _contactSense_R.translation.z = -dst_R
		emit_signal("onDrillContact",dst_L,dst_R)
	if _drillTip.is_colliding():
		rockTarget = _drillTip.get_collider().get_parent().get_parent()
		var tipLocation = _drillTip.get_collision_point()
		if contactPoint == null:
			contactPoint = translation
		if rockTarget.get("RL_CLASS") != null && rockTarget.RL_CLASS == "Rock":
			_drillDepth =  max(0,translation.z - _orgZ - contactPoint.z)
			emit_signal("onDrillTipContact",rockTarget,tipLocation,_drillTip.get_collision_normal(),_drillDepth)
	else:
		if contactPoint!=null:
			emit_signal("onDrillTipContact",null,null,null,0)
		contactPoint = null	
		
func toggleActivate()->bool:
	if(spin==0 && dst_L>0 && dst_R>0):
		_turnDrillOn()
		return true
	elif(spin!=0):
		_turnDrillOff()
		return true
	else:
		return false
		
func _turnDrillOn():
		spin = 1	
func _turnDrillOff():
		spin =  0
		direction = 0
	
		
func drill(pressure:float):
		_pressure = pressure
		pass
