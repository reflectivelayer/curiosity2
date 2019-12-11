extends Spatial
const GROW_LIMIT = 0.005
var isDrilling = true
var depth = 0.0
var _sinkRate = 0.001
var _hole:MeshInstance
var _timeDelta = 0.0
var _dig = 0.0
var _size = 0.0

func _ready():
	_hole = $holeImage

func _process(delta):
	_timeDelta = delta
	if _dig>0:
		scale = Vector3(_size,0.05,_size)
		_dig = 0

func drill()->float:
	_dig = _sinkRate*_timeDelta
	depth+=_dig
	if depth<GROW_LIMIT:
		_size = depth*6	#3 = adjusted number limit scale to 0.03
		scale = Vector3(_size,0.05,_size)
	if depth>0.03:_dig=0
	return _dig
