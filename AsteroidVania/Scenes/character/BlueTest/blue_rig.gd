class_name CharacterRig
extends Node2D

onready var animator : AnimationTree = $AnimationTree
onready var dolly : Node2D = $Dolly
onready var hand_l_remote : RemoteTransform2D = $Dolly/Skeleton2D/hip/chest/shoulderL/elbowL/handL/HandLRemote
onready var hand_r_remote : RemoteTransform2D = $Dolly/Skeleton2D/hip/chest/shoulderR/elbowR/handR/HandRRemote

onready var left_shoulder : Node2D = $Dolly/Skeleton2D/hip/chest/shoulderL

# parent things to hand
func parent_to_left_hand(path : NodePath):
	hand_l_remote.remote_path = path

# this shouldn't be accessible outside of the animator maybe should be on skeleton?
func rotate_arm_to(global_point : Vector2):
	
	var to_target = global_point - left_shoulder.global_position
	
	# hacky because of mirror flipping
	if dolly.scale.x <= 0:
		var target_flipped = Vector2(- to_target.x, to_target.y)
		left_shoulder.global_rotation = target_flipped.angle() + PI
	else:
		left_shoulder.global_rotation = to_target.angle()
	print("arm rotated, ", left_shoulder.global_rotation)
