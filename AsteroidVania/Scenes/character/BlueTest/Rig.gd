class_name Rig
extends Node2D

onready var left_shoulder : Node2D = $Dolly/Skeleton2D/hip/chest/shoulderL

func _process(delta):
#	var x = parent.velocity.rotated(parent.rotation).x
#
#	if x > 0:
#		scale = Vector2(-1,1)
#	else:
#		scale = Vector2(1,1)
#
#	scale *= 0.5
	pass

func rotate_arm_to(global_point : Vector2):
	var to_target = global_point - left_shoulder.global_position
	left_shoulder.rotation = to_target.angle()
