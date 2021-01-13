extends Node2D

onready var character = $KinematicCharacter

func _ready():

	get_node("/root/BulletHandler").set_level(self)
	print("test level set on bullethandler")
