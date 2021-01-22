extends StaticBody2D

# simple test turret don't duplicate architecture

export var target_manager_path : NodePath = "../TargetManager"
export var teleport_distance = 1000

onready var rng = RandomNumberGenerator.new()
onready var weapon = $Weapon
onready var target_manager = get_node(target_manager_path)

var player

func _ready():
	pass

func _process(delta):
	player = target_manager.get_target_node(target_manager.PLAYER)
	
	weapon.pull_trigger()
	
	# lead target
	
	var shot_time = (player.position - position).length() / weapon.muzzle_vel
	var displacement = (player.velocity * shot_time)
	
	var projected = player.position + displacement
	weapon.target = projected
	
	# rotate to shot
	
	rotation = lerp_angle(rotation, (projected - position).angle(), 0.4)

func teleport():
	
	$LootSpawner.spawn_loot()
	
	rng.randomize()
	var x = rng.randf_range(-teleport_distance,teleport_distance)
	var y = rng.randf_range(-teleport_distance,teleport_distance)
	position = Vector2(x,y)
