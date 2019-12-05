extends PanelContainer

signal powerToggle
signal mastMovment(direction,isOn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BtnPower_pressed():
	emit_signal("powerToggle")


func _on_BtnUp_button_down():
	emit_signal("mastMovment","up",true)
	
func _on_BtnUp_button_up():
	emit_signal("mastMovment","up",false)


func _on_BtnDown_button_down():
	emit_signal("mastMovment","down",true)

func _on_BtnDown_button_up():
	emit_signal("mastMovment","down",false)


func _on_BtnLeft_button_down():
	emit_signal("mastMovment","left",true)

func _on_BtnLeft_button_up():
	emit_signal("mastMovment","left",false)


func _on_BtnRight_button_down():
	emit_signal("mastMovment","right",true)

func _on_BtnRight_button_up():
	emit_signal("mastMovment","right",false)
