extends Spatial

var rover:VehicleBody
var sampler:RayCast
var _orgRock1 = preload("res://models/landscape/Rock1.tscn")
var _orgRock2 = preload("res://models/landscape/Rock2.tscn")
var _orgRock3 = preload("res://models/landscape/Rock3.tscn")
var _orgRock4 = preload("res://models/landscape/Rock4.tscn")
var _rockCount = 4
var _Drill:Spatial

func _ready():
	_Drill = $Rover/Arm/Lower/Upper/InstrumentBase/Instruments/Drill
	sampler = RayCast.new()
	add_child(sampler)
	sampler.enabled = true	
	sampler.cast_to = Vector3(0,100,0)	
	#$Rock.rotateCore( Vector3(7.361,51.352,-65.118))
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
	var maxRock = 50
	var count = 0
	var orgRocks = [_orgRock1,_orgRock2,_orgRock3,_orgRock4]
	var rock:Spatial
	var rng = RandomNumberGenerator.new()
	
	rng.randomize()
	while count < maxRock && safeCount<safe:
		sampler.force_raycast_update()
		sampler.translation = Vector3(rng.randf_range(-radius,radius),-1,rng.randf_range(-radius,radius))
		var target = sampler.get_collision_point()
		var normal = sampler.get_collision_normal()
		if abs(normal.x)<0.2 && abs(normal.z)<0.2:
			rock = orgRocks[rng.randi_range(0,_rockCount-1)].instance()
			rock.rotation = Vector3(rng.randf_range(0,PI*2),rng.randf_range(0,PI*2),rng.randf_range(0,PI*2))
			var scalJitterX = rng.randf_range(0,0.4)
			var scalJitterY = rng.randf_range(0,0.1)
			var scalJitterZ = rng.randf_range(0,0.4)
			add_child(rock)
			#rock.global_scale(Vector3(2,1,2))
			var aabb:AABB = rock.get_node("SolidMass").get_transformed_aabb()
			rock.translation = target+Vector3(0,-aabb.size.y/4,0)			
			count+=1
		safeCount+=1
	sampler.enabled = false
	print("Rocks placed: "+String(count))


