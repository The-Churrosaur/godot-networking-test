class_name Weapon
extends Node2D

export var bullet_prefab = preload("res://Scenes/character/weapons/bullet.tscn")
export var muzzle_path : NodePath
export var impulse = 300.0 
export var cycle_interval : float = 1 # seconds, rate of fire
export var is_automatic = false

# timers

# timer of the main gun cycle, handles firing
onready var cycle_timer : Timer = $CycleTimer

# bullet handler

onready var bullet_handler = get_node("/root/BulletHandler") # singleton
signal bullet_spawned(weapon, bullet, id)

# gun logic

# will shoot towards this point, global pos
var target : Vector2 = Vector2(0,0)
# from this point
var muzzle : Node2D
# ready to shoot
var in_battery : bool = true
var trigger_held : bool = false

func _ready():
	
	# set muzzle node from path
	muzzle = get_node(muzzle_path)
	
	# setup timers
	cycle_timer.one_shot = true
	cycle_timer.connect("timeout", self, "on_cycle")
	
	# register with handler
	bullet_handler.register_gun(self, name) # TODO guid?

# internal, instantly fires projectile
func fire_projectile():
	
	# spawn projectile
	var projectile = bullet_prefab.instance()
	projectile.global_position = muzzle.global_position
	
	# handler handles parenting to level
	emit_signal("bullet_spawned", self, projectile, projectile.name)
	
	assert (projectile is RigidBody2D)
	
	# fire at target
	var shot = (target - muzzle.global_position).normalized() * impulse
	projectile.rotation = shot.angle()
	projectile.apply_central_impulse(shot)

func pull_trigger():
	trigger_held = true
	try_fire()

func release_trigger():
	trigger_held = false

# firing sequence
func try_fire():
	if (in_battery):
		fire_projectile()
		in_battery = false
		cycle_timer.start(cycle_interval)
	else:
		#print("'click'")
		pass

# handles cycle timer
func on_cycle():
	in_battery = true
	# handle automatic fire
	if is_automatic && trigger_held:
		try_fire()
