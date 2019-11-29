extends PanelContainer

signal cameraDeploy
signal armMovment(section,direction,isOn)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BtnCamera_pressed():
	emit_signal("cameraDeploy")
	
func _on_BtnLeft_button_down(section):
		emit_signal("armMovment",section,"left",true)

func _on_BtnLeft_button_up(section):
		emit_signal("armMovment",section,"left",false)


func _on_BtnRight_button_down(section):
		emit_signal("armMovment",section,"right",true)


func _on_BtnRight_button_up(section):
		emit_signal("armMovment",section,"right",false)


