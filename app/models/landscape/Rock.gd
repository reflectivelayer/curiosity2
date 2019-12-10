extends Spatial
const MAX_DUST = 100
var _Hole = preload("res://models/landscape/DrillHole.tscn")

var drillOrigin:Vector3
var drillNormal:Vector3
var _depth:float = 0
var isDrilling = false
var rng:RandomNumberGenerator
var holes:Spatial
var done = false

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
func getDepth()->float:
	return _depth
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isDrilling && !done:
			_createHole()

func _createHole():
	holes = $Holes
	#hole.rotate(drillNormal.cross(hole.get_transform().basis.y).normalized(),hole.get_transform().basis.y.angle_to(drillNormal))

	print(drillNormal)
	
	var n1norm = $Rod.transform.basis.y
	var n2norm = drillNormal
	var cosa = n1norm.dot(n2norm)
	var alpha = acos(cosa)
	var axis = n1norm.cross(n2norm)
	axis = axis.normalized()
	$Rod.transform = $Rod.transform.rotated(axis, alpha)
	#$Rod.rotate_x(-PI/2)
	$Rod.translation = to_local(drillOrigin)
	
	var hole:MeshInstance = _Hole.instance()
	n1norm = hole.transform.basis.y
	n2norm = drillNormal
	cosa = n1norm.dot(n2norm)
	alpha = acos(cosa)
	axis = n1norm.cross(n2norm)
	axis = axis.normalized()
	hole.transform = hole.transform.rotated(axis, alpha)
	print(hole.transform)
	hole.translation = to_local(drillOrigin)
	hole.scale = Vector3(0.05,0.05,0.05)
	done = true
	holes.add_child(hole)

	
func rotateCore(rot:Vector3):
		$rock1.rotation = rot
