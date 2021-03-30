class_name CharacterRig
extends Node2D

onready var animator : AnimationTree = $AnimationTree
onready var dolly : Node2D = $Dolly
onready var hand_l_remote : RemoteTransform2D = $Dolly/Skeleton2D/hip/chest/shoulderL/elbowL/handL/HandLRemote
onready var hand_r_remote : RemoteTransform2D = $Dolly/Skeleton2D/hip/chest/shoulderR/elbowR/handR/HandRRemote

onready var left_shoulder : Bone2D = $Dolly/Skeleton2D/hip/chest/shoulderL
onready var right_shoulder : Bone2D = $Dolly/Skeleton2D/hip/chest/shoulderR
onready var right_elbow : Bone2D = $Dolly/Skeleton2D/hip/chest/shoulderR/elbowR

# parent things to hand
func parent_to_left_hand(path : NodePath):
	hand_l_remote.remote_path = path

# this shouldn't be accessible outside of the animator maybe should be on skeleton?
func rotate_arm_aiming(global_point : Vector2):
	
	var to_target = global_point - left_shoulder.global_position
	var angle
	
	# hacky because of mirror flipping
	if dolly.scale.x <= 0:
		var target_flipped = Vector2(- to_target.x, to_target.y)
		angle = target_flipped.angle() + PI
	else:
		angle = to_target.angle()
		left_shoulder.global_rotation = to_target.angle()
	
	left_shoulder.global_rotation = angle
	right_shoulder.global_rotation = (angle + PI)
#	right_elbow.global_rotation = abs(angle / PI)

