extends PanelContainer

signal drillAction(action,isOn)

var _contactLeft:Label
var _contactRight
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _ready():
	_contactLeft = $VBoxContainer/HBoxContainer2/DspContact_L
	_contactRight = $VBoxContainer/HBoxContainer2/DspContact_R
	
func setContactLeft(on:bool):
	var styleBox:StyleBoxFlat = _contactLeft.get_stylebox("normal" )
	if on:
		styleBox.bg_color = Color("#003399")
		_contactLeft.add_color_override("font_color",Color.white)
	else:
		styleBox.bg_color = Color("#6699ff")
		_contactLeft.add_color_override("font_color",Color.black)
		
func setContactRight(on:bool):
	var styleBox:StyleBoxFlat = _contactRight.get_stylebox("normal" )
	if on:
		styleBox.bg_color = Color("#003399")
		_contactRight.add_color_override("font_color",Color.white)
	else:
		styleBox.bg_color = Color("#6699ff")
		_contactRight.add_color_override("font_color",Color.black)

func _on_BtnMoveDrill_down(direction):
	emit_signal("drillAction",direction,true)

func _on_BtnMoveDrill_up(direction):
	emit_signal("drillAction",direction,false)
