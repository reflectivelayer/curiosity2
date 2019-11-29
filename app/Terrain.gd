extends Spatial

var rover:VehicleBody
var sampler:RayCast
func _ready():
	sampler = RayCast.new()
	add_child(sampler)
	sampler.enabled = true	
	sampler.cast_to = Vector3(0,100,0)	
	_place3dFeatures()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass#print(sampler.is_colliding())

func _place3dFeatures():
	_placeRocks()
	
	
func _placeRocks():
	var safe = 2000
	var safeCount = 0 
	var radius = 130
	var maxRock = 250
	var count = 0
	var orgMesh:Mesh = $Rock.mesh
	var meshInst:MeshInstance
	var rng = RandomNumberGenerator.new()

	
	while count < maxRock && safeCount<safe:
		sampler.force_raycast_update()
		sampler.translation = Vector3(rng.randf_range(-radius,radius),-1,rng.randf_range(-radius,radius))
		var target = sampler.get_collision_point()
		var normal = sampler.get_collision_normal()
		if normal.x>0 && normal.x<0.2:
			meshInst = MeshInstance.new()
			meshInst.mesh = orgMesh
			meshInst.translation = target
			meshInst.rotation = Vector3(rng.randf_range(0,PI*2),rng.randf_range(0,PI*2),rng.randf_range(0,PI*2))
			var scalJitter = rng.randf_range(0,0.1)
			meshInst.scale = Vector3(0.2+scalJitter,0.2+scalJitter,0.2+scalJitter)
			add_child(meshInst)
			count+=1
		safeCount+=1
	sampler.enabled = false
	print(count)

	