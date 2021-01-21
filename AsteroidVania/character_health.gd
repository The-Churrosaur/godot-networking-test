class_name CharacterHealth
extends Node

# optional healthbar to update automatically
export var use_health_bar = false
export var health_bar_path : NodePath = "../Hud/Hud/HealthBar"
export var starting_health = 5

signal health_changed(health)
signal health_zero()

var health : int = starting_health
var health_bar = null

func _ready():
	
	# setup healthbar
	if use_health_bar: health_bar = get_node(health_bar_path)

func change_health(i : int):
	
	health += i
	emit_signal("health_changed", health)
	
	# on zero
	if health <= 0:
		health = 0
		emit_signal("health_zero")
	
	# update attached health bar
	if use_health_bar:
		health_bar.change_health(i)

