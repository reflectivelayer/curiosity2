extends Spatial
var _Dust = preload("res://models/landscape/Dust.tscn")

var _depth:float = 0
var isDrilling = true
var _growthRate = 0.01
var _mesh:MeshInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	_mesh = $MeshInstance
	createDust()

func getDepth()->float:
	return _depth
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isDrilling:
		_depth+=_growthRate*delta
		_mesh.scale.y = _depth

func createDust():
	var dust = _Dust.instance()
	dust.scale = Vector3(0.3,0.3,0.3)
	$DustLayer.add_child(dust)
