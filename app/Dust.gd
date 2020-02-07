extends MeshInstance

var velocity:Vector3
var life:int = 60
var color:Color
var acc:float = 0.0002

func _ready():
	pass # Replace with function body.

func _process(delta):
	velocity.x+=acc
	translation.x+=velocity.x
	life-=1
	if life<=0:
		get_parent().remove_child(self)
		queue_free() 
	
func inits(position,velocity,scale,material):
	translation = position
	self.velocity = velocity
	self.scale = Vector3(scale,scale,scale)
	set_surface_material(0,material)
	
