extends MeshInstance

var MAX_DEPTH
var _depth = 0
var _drillRate = 0.0001
var _orgZ
var _direction = 0


func _ready():
	_orgZ = translation.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _direction!=0:
		rotate_z(0.2)
		_depth+=_drillRate*_direction
		translation.z = _orgZ+_depth
	
func engage():
	_direction=1
	pass
	
func disengage():
	_direction=-1
	pass