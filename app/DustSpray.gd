extends Spatial


var emitting:bool = false
var _dustCloud:Spatial
var Dust  = preload("res://Dust.tscn")
var x = 0
var rng  = RandomNumberGenerator.new()
var _scale:float = 0.004
var _baseMaterial:Material
var _color:Color
var _materials = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	_dustCloud = $DustCloud
	var dust = Dust.instance()
	_baseMaterial = dust.mesh.surface_get_material(0)
	dust.queue_free() 
	
	
func setStyle(scale:float, color:Color):
	_scale = scale
	_color = color
	if !_materials.has(color):
		var mat:Material = _baseMaterial.duplicate()
		mat.albedo_color  = color
		_materials[color] = mat

func _process(delta):
	if emitting:
		addGrain()

func addGrain():
	for c in range(3):
		var dust = Dust.instance()
		var pos = Vector3(rng.randf_range(-0.01,0.01),0,rng.randf_range(-0.01,0.01))
		dust.inits(pos,Vector3(),_scale,_getCurrentMaterial())
		_dustCloud.add_child(dust)

func _getCurrentMaterial()->Material:
	return _materials[_color]
