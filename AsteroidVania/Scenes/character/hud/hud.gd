extends CanvasLayer

# TODO look into viewports?
export var camera_path : NodePath
export var player_path : NodePath
export var health_bar_path : NodePath = "/Hud/HealthBar"

onready var camera = get_node(camera_path)
onready var player = get_node(player_path)
onready var health_bar = get_node(health_bar_path)

onready var pip_template = preload("res://Scenes/character/hud/pip.tscn")

# hud components

onready var jump_pips = $Hud/MarginContainer/JumpPips

func _ready():
	player.connect("jumping", self, "on_player_jump")
	player.connect("entered_platform", self, "on_player_land")

# test hud, add and remove pips

func add_pips(num):
	for i in num:
		var pip = pip_template.instance()
		jump_pips.add_child(pip)

func remove_pip(num):
	for i in num:
		if jump_pips.get_child_count() == 0: return
		var child = jump_pips.get_children()[0]
		jump_pips.remove_child(child)

# player manipulate jump pips

func on_player_jump():
	remove_pip(1)

func on_player_land(platform, normal):
	remove_pip(jump_pips.get_child_count())
	add_pips(player.boosts)
