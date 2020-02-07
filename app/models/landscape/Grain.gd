extends Reference
class_name Grain

var size:float
var color:Color

func _init(size:float, hexColor:String):
	self.size = size
	color = Color(hexColor)
