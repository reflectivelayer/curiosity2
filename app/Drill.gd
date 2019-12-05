extends Spatial
signal onDrillContact(contactA,contactB)

var MAX_DEPTH
var _depth = 0
var _drillRate = 0.0001
var _orgZ
var _direction = 0
var _contactA:RayCast
var _contactB:RayCast
var _contactDepthA
var _contactDepthB
var dstA
var dstB
var _isRotating = false
var _drillBit


func _ready():
	_contactA = $Contact_A
	_contactB = $Contact_B
	_drillBit = $DrillBit
	_orgZ = translation.z
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dstA = -1
	dstB = -1
	if _direction!=0:
		_depth+=_drillRate*_direction
		translation.z = _orgZ+_depth
	if _isRotating:
		_drillBit.rotate_z(0.2)
	var collider = _contactA.get_collider()
	if collider!=null:
		dstA = _contactA.get_collision_point().distance_to(_contactA.to_global(_contactA.cast_to))
	collider = _contactB.get_collider()
	if collider!=null:
		dstB = _contactB.get_collision_point().distance_to(_contactB.to_global(_contactA.cast_to))

	if dstA>=0 || dstB >=0:
		emit_signal("onDrillContact",dstA,dstB)

func lowerDrill(isOn):
	if isOn:
		_direction=1
	else:
		_direction=0

func raiseDrill(isOn):
	if isOn:
		_direction=-1	
	else:
		_direction=0

func activate(isOn):
	if isOn:
		_isRotating = !_isRotating

func _on_Drill_Contact(body, contactID):
	print("DDDD")
