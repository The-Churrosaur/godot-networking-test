class_name Weapon
extends Node2D

export var bullet_prefab = preload("res://Scenes/character/weapons/bullet.tscn")
export var muzzle_path : NodePath
export var shooter_path : NodePath
export var muzzle_vel = 300.0 
export var cycle_interval : float = 1 # seconds, rate of fire
export var is_automatic = false
export var num_projectiles = 1
export var spread = 0.1
export var inherit_velocity = false
export var velocity_minimum = false # if inherit velocity, absolute velocity will not drop below impulse 

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
# shooter
onready var shooter = get_node(shooter_path)
# random gen
onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# assigns bullet to group
var bullet_group = null

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
		
		# get shot direction
		var shot_dir = (target - muzzle.global_position).normalized()
		
		# inherit velocity
		if inherit_velocity:
			
			var shooter_vel
			if shooter is KinematicCharacter:
				shooter_vel = shooter.velocity
			elif shooter is RigidBody2D:
				shooter_vel = shooter.linear_velocity
			
			# enforce velocity minimum
			
			# if not checking for velocity minimum,
			# or, are checking and shot is in same direction as character, 
			# append velocity
			if velocity_minimum:
				# rebrain this
				if shot_dir.project(shooter_vel).normalized().rotated(-shooter_vel.angle()).x > 0:
					projectile.linear_velocity += shooter_vel
			else:
				projectile.linear_velocity += shooter_vel
		
		# calculate impulse
		var shot = shot_dir * muzzle_vel / projectile.mass
		
		# deviate projectile by spread
		rng.randomize()
		shot = shot.rotated(rng.randf_range(-spread, spread))
		
		# shoot shot
		projectile.rotation = shot.angle()
		projectile.apply_central_impulse(shot)
		
		# set bullet group
		if bullet_group != null:
			projectile.add_to_group(bullet_group)
	
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
		
		for i in num_projectiles:
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
