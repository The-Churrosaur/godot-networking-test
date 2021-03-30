extends AnimationTree

onready var rig = get_parent()
onready var tween = $Tween

func face_direction(dir : float = 0.0, tween_blend = false, tween_time = 0.2):
	
	if tween_blend:
		tween.interpolate_property(
			self, "parameters/left_right_blend/blend_position", 
			null, dir, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
			)
		tween.start()
	else:
		set("parameters/left_right_blend/blend_position", dir)

func run_stand( blend : float = 0.0, tween_blend = false, tween_time = 0.2):
	
	if tween_blend:
		tween.interpolate_property(
			self, 
			"parameters/run_stand_blend/blend_position", null,
			blend, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
			)
	else:
		set("parameters/run_stand_blend/blend_position", blend)

func floating_standing( blend : float = 0.0, tween_blend = false, tween_time = 0.2):
	
	if tween_blend:
		tween.interpolate_property(
			self, 
			"parameters/floating_standing_blend/blend_amount", null,
			blend, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
			)
	else:
		set("parameters/floating_standing_blend/blend_amount", blend)

func aiming(point : Vector2):
#	set("parameters/gun_rotate_blend/blend_amount", 0.5)
	rig.rotate_arm_aiming(point)
