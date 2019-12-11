extends Spatial
const RL_CLASS =  "Rock"	#work around for not being able to check if custom classes exist

const MAX_DUST = 100
var _Hole = preload("res://models/landscape/DrillHole.tscn")

var drillOrigin:Vector3
var drillNormal:Vector3
var _depth:float = 0
var isDrilling = false
var rng:RandomNumberGenerator
var holes:Spatial

var hole:Spatial  #TEMP ONLY

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
				
	
func getDepth()->float:
	return _depth
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func drill(pressure)->float:
	if hole==null:
		_createHole()
	return hole.drill(pressure)
		
func _createHole():
	holes = $Holes
	hole = _Hole.instance()
	var n1norm = hole.transform.basis.y
	var n2norm = drillNormal
	var cosa = n1norm.dot(n2norm)
	var alpha = acos(cosa)
	var axis = n1norm.cross(n2norm)
	axis = axis.normalized()
	hole.transform = hole.transform.rotated(axis, alpha)
	hole.translation = to_local(drillOrigin)
	hole.rotate_x(-rotation.x)
	hole.rotate_y(-rotation.y)
	hole.rotate_z(-rotation.z)
	hole.scale = Vector3(0.0,0.05,0.0)
	holes.add_child(hole)
