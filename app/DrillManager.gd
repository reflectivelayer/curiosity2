extends Reference
class_name DrillManager

signal onStopArm()
signal onShakeSample()

var DRILL_FORCE:float = 0.001
var sampleContainer = {}
var isDrilling:bool = false
var _sampleVolume:int
var _drill:Drill
var _drillUI:DrillUI
var _rockContact:bool = false
var _target
var _anim:Animation
var _drillBit:MeshInstance
var _animator:AnimationPlayer
var _chassisAnimator:AnimationPlayer
var _cheMinCoverOpen:bool = false
var _sam1CoverOpen:bool = false
var _sam2CoverOpen:bool = false
var _prevDrillDepth:int = 0
var pourValve
var _sampleRatios = []
var _rng = RandomNumberGenerator.new()

func _init(rover:VehicleBody):
	_drill = rover.get_node("Arm/Lower/Upper/InstrumentBase/Instruments/Drill")
	_drillUI = rover.get_node("../Control/DrillRect/Drill")
	_animator = rover.get_node("Arm/Animator")
	_chassisAnimator = rover.get_node("Chassis/ChassisAnimator")
	_anim = _animator.get_animation("PreDrill")
	_drillBit = rover.get_node("Arm/Lower/Upper/InstrumentBase/Instruments/Drill/DrillBit")
	
	_drillUI.connect("drillAction",self,"_onDrillAction")
	_drillUI.connect("coverAction",self,"_onCoverAction")
	_drill.connect("onDrillContact",self,"_onDrillContact")
	_drill.connect("onDrillTipContact",self,"_onDrillTipContact")
	_drill.connect("onDrillParked",self,"_onDrillParked")
	_animator.connect("animation_finished", self, "_animationCompleted")
	
func update():
	if _drill.direction!=0 || _drill.spin != 0:
		if _drill.direction == 1:
			_drill.drill(DRILL_FORCE*_drill.spin)
		elif _drill.direction == -1:
			_drill.drill(-DRILL_FORCE*10)
	if _sampleVolume>0:
		_updatePour()

func lower():
	pass
	
func raise():
	pass
	
func start():
	pass

func stop():
	pass
	
func startPour(pourValve):
	self.pourValve = pourValve
	self.pourValve.emitting = true 
	_sampleRatios.clear()
	_sampleVolume = 0
	for grain in sampleContainer.keys():
		_sampleVolume += sampleContainer[grain]
	for grain in sampleContainer.keys():
		_sampleRatios.append(SampleRatio.new(grain,sampleContainer[grain]/float(_sampleVolume)))
	
func _updatePour():
		_sampleVolume-=4
		var pouring = _sampleVolume>0
		for sampleRatio in _sampleRatios:
			if _rng.randf() < sampleRatio.ratio:
				pourValve.setStyle(sampleRatio.grain.size,sampleRatio.grain.color)
		if !pouring:
			pourValve.emitting = false
			
		
func _onDrillAction(direction,isOn):
	if !isDrilling:
		if direction == "down":
			if isOn:
				if _rockContact:
					_drill.direction = 1
			else:
				_drill.direction = 0	
		elif direction == "up":
			if isOn:
				_drill.direction = -1
			else:
				_drill.direction = 0
		elif direction == "activate":
			if isOn:
				if _rockContact && _target!=null:
					isDrilling = true
					_startPreDrill()

	
func _onDrillContact(contactA,contactB):
	if contactA>=0.04 || contactB>=0.04:
		emit_signal("onStopArm")
	elif  contactA>=0.01 && contactB>=0.01:
		_rockContact = true
	else:
		_rockContact = false
		_target = null
	_drillUI.setContactLeft(contactA>=0.01) 
	_drillUI.setContactRight(contactB>=0.01)
	
func _onDrillTipContact(target,contactPoint,normal,drillDepth):
	if target!=null:
		target.drillOrigin = contactPoint
		target.drillNormal = normal
		target.isDrilling = true
		_drillUI.setDepth(drillDepth)
		if _drill.spin!=0 && _prevDrillDepth!=drillDepth:
			_fillSampleContainer(target.getLayerAt(drillDepth))
			_prevDrillDepth = drillDepth
		if _drill.spin!=0 && drillDepth > 0.02:	#Stop drill and pull out
			_drill.direction = -1
			_drill.spin = 0
	_target = target
	
func _onDrillParked():
	isDrilling = false
	
func _onCoverAction(cover:String):
	match cover:
		"SAM_cover1":
			if _sam1CoverOpen:
				_chassisAnimator.play_backwards(cover)
			else:
				_chassisAnimator.play(cover)
			_sam1CoverOpen = !_sam1CoverOpen
		"SAM_cover2":
			if _sam2CoverOpen:
				_chassisAnimator.play_backwards(cover)
			else:
				_chassisAnimator.play(cover)
			_sam2CoverOpen = !_sam2CoverOpen
		"CheMin_cover":
			if _cheMinCoverOpen:
				_chassisAnimator.play_backwards(cover)
			else:
				#_chassisAnimator.play(cover)
				emit_signal("onShakeSample")				
			_cheMinCoverOpen = !_cheMinCoverOpen

func _startPreDrill():
	var trackIndex = _anim.find_track("Lower/Upper/InstrumentBase/Instruments/Drill/DrillBit:translation")
	for i in range(0,6):
		_anim.track_set_key_value(trackIndex,i*2,_drillBit.translation)
		if i<5:
			var upStop = _drillBit.translation
			upStop.z-=0.012
			_anim.track_set_key_value(trackIndex,i*2+1,upStop)
		
	_animator.play("PreDrill")
	

func _animationCompleted(animation):
	if(animation == "PreDrill"):
		_drill.toggleActivate()
		_drill.direction  = _drill.spin

func _fillSampleContainer(layer:RockLayer):
	if layer != null:
		var count
		for grain in layer.grains:
			count = sampleContainer.get(grain)
			if count != null:
				sampleContainer[grain]+=layer.drillSpeedMultiplier
			else:
				sampleContainer[grain] = layer.drillSpeedMultiplier

class SampleRatio:
	var grain:Grain
	var ratio:float
	
	func _init(grain:Grain, ratio:float):
		self.grain = grain
		self.ratio = ratio
