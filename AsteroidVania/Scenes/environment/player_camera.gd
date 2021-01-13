class_name PlayerCamera
extends Camera2D

export var player_path : NodePath
export var follow_lerp = 0.1
export var follow_lerp_angle = 0.1

var player : KinematicBody2D

func _ready():
	player = get_node(player_path)

func _process(delta):
	
	# follow player
	position = lerp(position, player.position, follow_lerp)
	rotation = lerp_angle(rotation, player.rotation, follow_lerp_angle)

