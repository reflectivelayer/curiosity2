extends PanelContainer

signal driveMovment(direction,isOn)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pas

func _on_BtnUp_button_down():
	emit_signal("driveMovment","up",true)

func _on_BtnUp_button_up():
	emit_signal("driveMovment","up",false)

func _on_BtnLeft_button_down():
	emit_signal("driveMovment","left",true)

func _on_BtnLeft_button_up():
	emit_signal("driveMovment","left",false)

func _on_BtnRight_button_down():
	emit_signal("driveMovment","right",true)

func _on_BtnRight_button_up():
	emit_signal("driveMovment","right",false)

func _on_BtnDown_button_down():
	emit_signal("driveMovment","down",true)

func _on_BtnDown_button_up():
	emit_signal("driveMovment","down",false)
