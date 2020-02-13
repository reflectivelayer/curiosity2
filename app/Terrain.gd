extends Spatial

var rover:VehicleBody
var sampler:RayCast
var _orgRock1 = preload("res://models/landscape/Rock1.tscn")
var _orgRock2 = preload("res://models/landscape/Rock2.tscn")
var _orgRock3 = preload("res://models/landscape/Rock3.tscn")
var _orgRock4 = preload("res://models/landscape/Rock4.tscn")
var _rockCount = 4
var _Drill:Spatial
var _grains = [[Grain.new(0.001,"#a97333")],[Grain.new(0.002,"#927647")],[Grain.new(0.001,"#8dc9ca")],[Grain.new(0.002,"#58626c")]]
var _rng = RandomNumberGenerator.new()
var _hotSpotCount = 4
var _hotSpots = []
var _hotSpotRadius = 25

func _ready():
	_rng.randomize()
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
	var maxRock = 100
	var count = 0
	var orgRocks = [_orgRock1,_orgRock2,_orgRock3,_orgRock4]
	var rock:Spatial


	while count < _hotSpotCount && safeCount<safe:
		sampler.force_raycast_update()
		sampler.translation = Vector3(_rng.randf_range(-radius,radius),-1,_rng.randf_range(-radius,radius))
		var target = sampler.get_collision_point()
		var normal = sampler.get_collision_normal()
		if abs(normal.x)<0.2 && abs(normal.z)<0.2:
			_hotSpots.append(target)
			count+=1
		safeCount+=1


	count = 0
	while count < maxRock && safeCount<safe:
		sampler.force_raycast_update()
		
		if(_rng.randi_range(0,4) == 1):
			sampler.translation = Vector3(_rng.randf_range(-radius,radius),-1,_rng.randf_range(-radius,radius))	
		else:
			var hotspotOffset = Vector3(_rng.randi_range(-_hotSpotRadius,_hotSpotRadius),-1,_rng.randi_range(-_hotSpotRadius,_hotSpotRadius))
			sampler.translation = _hotSpots[_rng.randi_range(0,_hotSpotCount-1)]+hotspotOffset
						
		var target = sampler.get_collision_point()
		var normal = sampler.get_collision_normal()
		if abs(normal.x)<0.2 && abs(normal.z)<0.2:
			rock = orgRocks[_rng.randi_range(0,_rockCount-1)].instance()
			rock.rotateCore(Vector3(_rng.randf_range(0,PI*2),_rng.randf_range(0,PI*2),_rng.randf_range(0,PI*2)))
			var scalJitterX = _rng.randf_range(0,0.4)
			var scalJitterY = _rng.randf_range(0,0.1)
			var scalJitterZ = _rng.randf_range(0,0.4)
			addLayers(rock)
			add_child(rock)
			#rock.global_scale(Vector3(2,1,2))
			var aabb:AABB = rock.get_node("SolidMass").get_transformed_aabb()
			rock.translation = target+Vector3(0,-aabb.size.y/4,0)			
			count+=1
		safeCount+=1
	sampler.enabled = false
	print("Rocks placed: "+String(count))
	addLayers($Rock)

func addLayers(rock):
	var layers = []
	var grain = _grains[_rng.randi_range(0,_grains.size()-1)]
	for c in range(_rng.randi_range(1,3)):
		layers.append(RockLayer.new(_rng.randf_range(0.005,0.04),_rng.randf_range(0.1,0.9),grain))
	
	layers.sort_custom(self,"layerDepthComparison")
	layers[layers.size()-1].bottomDepth = 0.04	#Depth limit
	rock.rockLayers = layers

func layerDepthComparison(a:RockLayer, b:RockLayer):
		return a.bottomDepth < b.bottomDepth
