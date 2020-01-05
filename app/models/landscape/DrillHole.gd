extends Spatial
const GROW_WIDTH_LIMIT = 0.005
var isDrilling = true
var depth = 0.0
var relativeEntryPoint:Vector3
var rockLayers:Array
var _sinkRate = 0.001
var _hole:MeshInstance
var _timeDelta = 0.0
var _dig = 0.0
var _size = 0.0
var _holeFloor = 0

func _ready():
	_hole = $holeImage

func _process(delta):
	_timeDelta = delta
	if _dig>0:
		scale = Vector3(_size,0.05,_size)
		_dig = 0

func drill(location:Vector3, pressure:float)->float:
	var dig = 0
	var layer:RockLayer = getRockLayerAt(depth)
	if location.z>=relativeEntryPoint.z+_holeFloor:
		if depth>0.03:_sinkRate = 0
		dig = min(pressure,_sinkRate*layer.drillSpeedMultiplier)*_timeDelta
		depth = location.z-relativeEntryPoint.z
		if depth >= _holeFloor: _holeFloor=depth		
		if _holeFloor<GROW_WIDTH_LIMIT:
			_size = depth*7	#3 = adjusted number limit scale to 0.03
			scale = Vector3(_size,0.05,_size)
	else:
		if depth>0.03:_sinkRate = 0
		dig = _sinkRate*_timeDelta*5
		depth = location.z-relativeEntryPoint.z
		if depth >= _holeFloor: _holeFloor=depth
		if _holeFloor<GROW_WIDTH_LIMIT:
			_size = _holeFloor*7	#3 = adjusted number limit scale to 0.03
			scale = Vector3(_size,0.05,_size)
	return dig

func getRockLayerAt(depth):
	for layer in rockLayers:
		if depth < layer.bottomDepth:
			return layer
	return null
