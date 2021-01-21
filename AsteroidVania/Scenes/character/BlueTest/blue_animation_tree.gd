extends AnimationTree

# todo, lerps/transitions or somthing

func face_direction(dir : float = 0.0):
	set("parameters/left_right_blend/blend_position", dir)

func run_stand( blend : float = 0.0):
	set("parameters/run_stand_blend/blend_position", blend)

func floating_standing( blend : float = 0.0):
	set("parameters/floating_standing_blend/blend_amount", blend)
