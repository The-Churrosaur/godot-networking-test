class_name CharacterHealth
extends Node

export var starting_health  : int

signal health_changed(health)
signal health_zero()

onready var health : int = starting_health
var health_bar = null

func _ready():
	pass

func change_health(i : int):
	
	print(i, health)
	health += i
	emit_signal("health_changed", health)
	
	# on zero
	if health <= 0:
		health = 0
		emit_signal("health_zero")

func reset_health():
	change_health(starting_health - health)

