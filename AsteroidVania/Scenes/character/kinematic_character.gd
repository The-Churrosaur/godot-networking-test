class_name KinematicCharacter
extends KinematicBody2D

# params

export var magwalk_velocity = 100 # pixels/tick
export var magwalk_gravity = 10 # velocity towards surface
export var magwalk_ang_lerp = 0.2
export var jump_velocity = 100
export var gravity_ang_lerp = 0.05
export var dodge_distance = 100
export var boost_impulse = 100

export var boost_limited = true # boost as double jump
export var boost_number = 3

# control flags - write from player/ai controller 

var should_magwalk_left = false
var should_magwalk_right = false

var should_boost = false
var boost_dir : Vector2 = Vector2(0,0)

var magwalk_enabled = true # if false overridden by planet gravity
var should_jump = false # auto resets
var jump_towards : Vector2 = Vector2(0,0)

# platform information

var on_platform = false
var platform = null
var platform_normal : Vector2
var platform_collision : KinematicCollision2D
var just_landed = false # auto resets

# physics dummy

onready var physics_dummy_preload = preload("res://Scenes/character/CharacterPhysicsDummy.tscn")
var physics_dummy_instance : RigidBody2D = null
var physics_dummy_spawned = false

# physics dummy gravity

var in_gravity = false
var gravity_area : Area2D = null

# global per-tick movement vector

var displacement : Vector2
var velocity : Vector2
var last_position : Vector2 = position
var mns_displacement : Vector2

# jumping and movement

var boosts = boost_number

func _ready():
	# test, start by moving down, facing up
	displacement = Vector2(0,40) 
	platform_normal = Vector2(0,-1)

func _physics_process(delta):
	
	# update last position, velocity
	velocity = (position - last_position) / delta
	last_position = position
	
	# if floating - 
	# follow dummy, moveandcollide, rotate to gravity
	if !on_platform : 
		
		# if dummy -
		# set dv to physics dummy velocity
		if physics_dummy_spawned:
			displacement = physics_dummy_instance.linear_velocity
			
			# if in grav, rotate feet to planet
			#rotate_towards_grav()
		
		# move
		var collision =  move_and_collide(displacement * delta, false)
		
		# on collide
		if (collision != null):
			print("collision")
			# gravityplatforms override
			if (collision.collider.is_in_group("GravityPlatform") || 
				magwalk_enabled && collision.collider.is_in_group("Platform")):
				enter_platform(collision)
	
	# if on platform - 
	# handle snapping, magbooting, jumping
	else: 
		
		# move, then reset displacement for next tick --
		
		# move 
		var snap_vector = platform_normal * -50
		mns_displacement = move_and_slide_with_snap(displacement, snap_vector, platform_normal, false, 10, 4*PI, false)
		
		# set flags and delta velocity for next move --
		
		# lerp rotate to normal - how does this work lol 
		rotation = lerp_angle(rotation, platform_normal.angle() + PI/2, magwalk_ang_lerp)
		
		# reset velocity
		displacement = Vector2(0,0)
		
		# push towards platform
		displacement += -platform_normal * magwalk_gravity
		
		# add magwalk velocity tangent to normal
		if should_magwalk_left:
			displacement += platform_normal.tangent() * magwalk_velocity
		if should_magwalk_right:
			displacement += -platform_normal.tangent() * magwalk_velocity
		
		# for rotating platforms, calculates surface velocity and matches --
		var rotating_surface = match_surface_velocity()
		
		# update normal --
		update_normal()
	
	# jump - leaves platform and punts the dummy
	if (should_jump):
		if boosts <= 0:
			print("out of boosts")
			should_jump = false
		else:
			if on_platform: jump(jump_towards, jump_velocity)
			else: dodge(jump_towards, jump_velocity)
			should_jump = false
			boosts -= 1
	
	# boost - directional impulse by WASD if not walking
	if should_boost && !on_platform:
		dodge(position + boost_dir.rotated(rotation), boost_impulse)
		should_boost = false

# PHYSICS_UPDATE HELPER METHODS --

# if in grav, rotate feet to planet
func rotate_towards_grav():
	
	if in_gravity && gravity_area != null:
		var target : Vector2
		# if point
		if gravity_area.gravity_point:
			target = gravity_area.position - position
		# if linear
		else:
			target = gravity_area.gravity_vec
		# rotate
		rotation = lerp_angle(rotation, target.angle(), gravity_ang_lerp)

# for rotating platforms, calculates surface velocity and matches
func match_surface_velocity() -> bool:
	
	var radius = position - platform.position
	var angular_velocity
	
	if platform is RigidBody2D:
		angular_velocity = platform.angular_velocity
	if platform.is_in_group("WalkableSurface"):
		angular_velocity = platform.physics_dummy_instance.angular_velocity
	else:
		return false
	
	var tangent_normal = radius.tangent().normalized()
	var surface_vel = - radius.length() * angular_velocity * tangent_normal
	displacement += surface_vel
	
	return true

func update_normal():
	# if just landed, use normal from previous loop collision
	if just_landed:
		print("just landed")
		just_landed = false
	# else check moveandslide
	else:
		platform_normal = get_floor_normal()
		# if broke away from platform last tick
		if platform_normal == Vector2(0,0):
			print("boing")
			leave_platform()

# jump - leaves platform and punts the dummy
func jump(target, velocity):
	
	print("jumping")
	leave_platform()
	
	# punt dummy
	var impulse = (target - position).normalized() * velocity
	if physics_dummy_spawned:
		physics_dummy_instance.apply_central_impulse(impulse)
	else:
		print("the physics dummy is missing")

# does jump but zeroes velocity first
func dodge(target, velocity):
	
	print("dodging")
	
	despawn_physics_dummy()
	spawn_physics_dummy()
	
	jump(target, velocity)

func enter_platform(collision : KinematicCollision2D):
	print("entering platform: ", collision.normal)
	platform = collision.collider
	platform_normal = collision.normal
	platform_collision = collision
	
	just_landed = true
	on_platform = true
	
	despawn_physics_dummy()
	
	boosts = boost_number

func leave_platform():
	print("leaving platform")
	platform_normal = Vector2(0,0)
	on_platform = false
	
	spawn_physics_dummy()

# PHYSICS DUMMY METHODS --

func spawn_physics_dummy():
	
	if physics_dummy_instance != null:
		print("physics dummy already exists")
		return
	
	physics_dummy_instance = physics_dummy_preload.instance()
	physics_dummy_instance.position = position
	get_parent().add_child(physics_dummy_instance)
	physics_dummy_spawned = true
	
	physics_dummy_instance.connect("gravity_area_entered", self, "on_dummy_enter_grav")
	physics_dummy_instance.connect("gravity_area_left", self, "on_dummy_leave_grav")

func despawn_physics_dummy():
	
	if physics_dummy_instance != null:
		get_parent().remove_child(physics_dummy_instance)
		physics_dummy_instance.queue_free()
		physics_dummy_instance = null
		physics_dummy_spawned = false
	else:
		print("physics dummy already null")

func on_dummy_enter_grav(area):
	in_gravity = true
	gravity_area = area

func on_dummy_leave_grav(area):
	in_gravity = false
	gravity_area = null


