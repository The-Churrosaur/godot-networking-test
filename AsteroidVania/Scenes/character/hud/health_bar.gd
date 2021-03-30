class_name HealthBar
extends Control

# tracks target health node
export var char_health_path : NodePath
export var health_box_path : NodePath = "/MarginContainer/HBoxContainer"
export var health_pip_resource : PackedScene  = preload("res://Scenes/character/hud/health_pip_small.tscn")

onready var char_health = get_node(char_health_path)
onready var health_box = get_node(health_box_path)

var health_displayed = 0 # no touch

func _ready():
	
	# connect to character health, set starting health
	if char_health != null:
		char_health.connect("health_changed", self, "set_health")
		set_health(char_health.starting_health)

func set_health(health : int):
	var dif = health - health_displayed
	change_health(dif)

func add_health(health : int):
	for i in health:
		health_box.add_child(health_pip_resource.instance())
		health_displayed += 1

func remove_health(health : int):
	for i in health:
		if health_box.get_child_count() <= 0:
			return
		# remove first child
		health_box.remove_child(health_box.get_children()[0])
		health_displayed -= 1

func change_health(health : int):
	if health > 0: add_health(health)
	else: remove_health(health * -1)

func get_health_children():
	return health_box.get_children()
