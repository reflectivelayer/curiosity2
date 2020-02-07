extends Spatial
const RL_CLASS =  "Rock"	#work around for not being able to check if custom classes exist

const MAX_DUST = 100
var _Hole = preload("res://models/landscape/DrillHole.tscn")

var drillOrigin:Vector3
var drillNormal:Vector3
var isDrilling = false
var rng:RandomNumberGenerator
var holes:Spatial
var rockLayers:Array = []

var hole:Spatial  #TEMP ONLY

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var grains1 = [Grain.new(0.002,"#a97333")]
	var grains2 = [Grain.new(0.004,"#927647")]
	rockLayers.append(_createRockLayer(0.0175,0.75,grains1))
	rockLayers.append(_createRockLayer(0.04,0.25,grains2))

func getDepth()->float:
	return hole.depth

func getGrainsAt(depth)->Grain:
	if hole != null:
		return hole.getRockLayerAt(depth).grain
	else:
		return null
	

func rotateCore(rot:Vector3):
	$SolidMass.rotation = rot

func scaleCore(sc:Vector3):
	$SolidMass.scale = sc

func drill(location,pressure)->float:
	if hole==null:
		_createHole(location)
	return hole.drill(location,pressure)

func _createHole(location:Vector3):
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
	hole.scale = Vector3(0.0,0.05,0.0)
	hole.relativeEntryPoint = location
	hole.rockLayers = rockLayers
	holes.add_child(hole)


func _createRockLayer(height:float, drillSpeed:float,grains:Array)->RockLayer:
	var rockLayer:RockLayer = RockLayer.new(height,drillSpeed,grains)
	return rockLayer
