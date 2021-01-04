extends Node2D

onready var camera = $Camera2D
onready var character = $KinematicCharacter

func _ready():
	camera.make_current()

func _process(delta):
	camera.position = lerp(camera.position, character.position, 0.5)
	camera.rotation = lerp_angle(camera.rotation, character.rotation, 0.1)
