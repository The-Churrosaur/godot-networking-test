extends Node2D

onready var camera = $Camera2D
onready var character = $KinematicCharacter

func _ready():
	camera.make_current()
	# TODO level switcher singleton
	get_node("/root/BulletHandler").set_level(self)
	print("test level set on bullethandler")

func _process(delta):
	camera.position = lerp(camera.position, character.position, 0.1)
	camera.rotation = lerp_angle(camera.rotation, character.rotation, 0.1)
