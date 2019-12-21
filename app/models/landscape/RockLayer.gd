extends Reference
class_name RockLayer

var bottomDepth:float = 0		#depth from surface
var drillSpeedMultiplier:float = 0
var grain:Array 

func _init(bottomDepth:float, drillSpeedMultiplier:float,grains:Array):
	self.bottomDepth = bottomDepth
	self.drillSpeedMultiplier = drillSpeedMultiplier
	self.grain = grains
