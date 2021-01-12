extends StaticBody2D

# simple test turret don't duplicate architecture

export var player_path : NodePath

onready var weapon = $Weapon
onready var player = get_node(player_path)

func _ready():
	print(player)

func _process(delta):
	weapon.pull_trigger()
	
	# lead target
	
	var shot_time = (player.position - position).length() / weapon.impulse
	var displacement = (player.velocity * shot_time)

	var projected = player.position + displacement
	weapon.target = projected
