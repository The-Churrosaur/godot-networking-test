class_name PlayerCamera
extends Camera2D

export var player_path : NodePath
export var follow_lerp = 0.1
export var follow_lerp_angle = 0.1
export var follow_on_magwalk = true

onready var player : KinematicBody2D  = get_node(player_path)
var following_rotation = true

func _ready():
	player.connect("entered_platform", self, "on_platform_entered")
	player.connect("left_platform", self, "on_platform_left")

func _process(delta):
	
	# follow player
	position = lerp(position, player.position, follow_lerp)
	
	# follow rotation
	if following_rotation:
		rotation = lerp_angle(rotation, player.rotation, follow_lerp_angle)

func on_platform_entered(platform, normal):
	if !follow_on_magwalk: following_rotation = false

func on_platform_left():
	if !follow_on_magwalk: following_rotation = true

