extends StaticBody2D

# simple test turret don't duplicate architecture

export var player_path : NodePath
export var teleport_distance = 1000

onready var rng = RandomNumberGenerator.new()
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
	
	# rotate to shot
	
	rotation = lerp_angle(rotation, (projected - position).angle(), 0.4)

func teleport():
	rng.randomize()
	var x = rng.randf_range(-teleport_distance,teleport_distance)
	var y = rng.randf_range(-teleport_distance,teleport_distance)
	position = Vector2(x,y)
