extends Spatial
signal onDrillContact(contactA,contactB)
signal onDrillTipContact(target,contactPoint, normal, drillDepth)

var MAX_DEPTH = 0.065  # 6.5cm
var rockTarget:Spatial
var isRotating = false
var direction = 0
var _depth = 0
var _drillDepth = 0
var _drillRate = 0.02
var _orgZ
var _contactA:RayCast
var _contactB:RayCast
var _contactDepthA
var _contactDepthB
var dstA = 0 
var dstB = 0 
var _drillBit
var _drillTip:RayCast
var _contactPoint = null
var _dig = 0.0


func _ready():
	_contactA = $"../Contact_A"
	_contactB = $"../Contact_B"
	_drillBit = $DrillBit
	_drillTip = $DrillBit/Tip
	_orgZ = translation.z
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _contactPoint!=null && direction==1 && !isRotating:  #Stop lowering drill when not spinning
		direction=0
	elif _drillDepth > MAX_DEPTH && direction == 1:
		_turnDrillOff()
	dstA = -1
	dstB = -1
	if direction!=0:
		if direction == 1 || translation.z>= _orgZ:
			_depth+=_drillRate*direction*delta
			translation.z = _orgZ+_depth + _drillDepth
	if isRotating:
		_drillBit.rotate_z(0.2)
		translation.z+=_dig
	var collider = _contactA.get_collider()
	if collider!=null:
		dstA = _contactA.get_collision_point().distance_to(_contactA.to_global(_contactA.cast_to))
	collider = _contactB.get_collider()
	if collider!=null:
		dstB = _contactB.get_collision_point().distance_to(_contactB.to_global(_contactA.cast_to))

	if dstA>=0 || dstB >=0:
		emit_signal("onDrillContact",dstA,dstB)
	if _drillTip.is_colliding():
		rockTarget = _drillTip.get_collider().get_parent().get_parent()
		var tipLocation = _drillTip.get_collision_point()
		if _contactPoint == null:
			_contactPoint = translation
		#_drillDepth = _contactPoint.distance_to(translation)
		if rockTarget.get("RL_CLASS") != null && rockTarget.RL_CLASS == "Rock":
			emit_signal("onDrillTipContact",rockTarget,tipLocation,_drillTip.get_collision_normal(),_drillDepth)

	else:
		_contactPoint = null	
		
func lowerDrill(isOn)->bool:
	if(dstA>0 && dstB>0 && _contactPoint==null):
		if isOn:
			if _contactPoint==null:
				direction=1
		else:
			direction=0
		return true
	else:
		return false

func raiseDrill(isOn):
	if isOn:
		direction=-1	
	else:
		direction=0

func activate(isPressed)->bool:
	if(isPressed && !isRotating && dstA>0 && dstB>0):
		_turnDrillOn()
		return true
	elif(isPressed && isRotating):
		_turnDrillOff()
		return true
	else:
		return false
		
func _turnDrillOn():
		isRotating = true	
func _turnDrillOff():
		isRotating = false
		direction = 0
		
func drill(pressure:bool):
	if rockTarget!=null:
		_dig = rockTarget.drill(pressure)
		_drillDepth += _dig
