class_name Weapon
extends Node2D

export var bullet_prefab = preload("res://Scenes/character/weapons/bullet.tscn")
export var muzzle_path : NodePath
export var impulse = 300.0 
export var cycle_interval : float = 1 # seconds, rate of fire
export var is_automatic = false

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
# current projectile
var current_projectile = null

func _ready():
	
	# set muzzle node from path
	muzzle = get_node(muzzle_path)
	
	# register with handler
	bullet_handler.register_gun(self, name) # TODO guid?

# internal, instantly fires projectile
func fire_projectile():
	
	# spawn projectile
	
	var projectile = bullet_prefab.instance()
	projectile.global_position = muzzle.global_position
	
	# handler handles parenting to level
	emit_signal("bullet_spawned", self, projectile, projectile.name)
	
	# fire at target
	
	if (projectile is RigidBody2D):
		var shot = (target - muzzle.global_position).normalized() * impulse
		projectile.rotation = shot.angle()
		projectile.apply_central_impulse(shot)
	
	# connect projectile
	
	current_projectile = projectile
	projectile.connect("bullet_impacted", self, "on_bullet_impact")

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
		
		# yield timer while cycling
		yield(get_tree().create_timer(cycle_interval), "timeout")
		
		in_battery = true
		
		# handle automatic fire
		if is_automatic && trigger_held:
			try_fire()
		
	else:
		#print("'click'")
		pass

# collects bullet impact
func on_bullet_impact(bullet, body):
	pass
