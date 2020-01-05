extends Reference
class_name DrillManager

signal onStopArm()

var DRILL_FORCE:float = 0.001
var _drill:Drill
var _drillUI:DrillUI
var _rockContact:bool = false
var _target
var _anim:Animation
var _drillBit:MeshInstance
var _animator:AnimationPlayer
var _isDrilling:bool = false

func _init(drill:Drill, drillUI:DrillUI,drillBit:MeshInstance,anim:Animation,animator:AnimationPlayer):
	_drill = drill
	_drillUI = drillUI
	_anim = anim
	_animator = animator
	_drillBit = drillBit
	_drillUI.connect("drillAction",self,"_onDrillAction")
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

func lower():
	pass
	
func raise():
	pass
	
func start():
	pass

func stop():
	pass
	
func _onDrillAction(direction,isOn):
	if !_isDrilling:
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
					_isDrilling = true
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
		if _drill.spin!=0 && drillDepth > 0.02:	#Stop drill and pull out
			_drill.direction = -1
			_drill.spin = 0
	_target = target
	
func _onDrillParked():
	_isDrilling = false
	
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
