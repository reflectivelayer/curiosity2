extends RigidBody

var org:Vector3
# Called when the node enters the scene tree for the first time.
func _ready():
	org = translation

func _physics_process(delta):
	if mode == MODE_RIGID && linear_velocity.length()>0.02:
		add_central_force(-linear_velocity.normalized()*3)
	else:
		if org.distance_squared_to(translation)<0.001:
			removeGrain()	
		else:
			mode = MODE_STATIC
	if org.y-translation.y>0.1:
		removeGrain()
	
func removeGrain():
	get_parent().remove_child(self)
	queue_free()	
