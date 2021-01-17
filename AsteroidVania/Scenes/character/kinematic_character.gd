class_name KinematicCharacter
extends KinematicBody2D

# params

export var rotational_velocity = 0
export var rotational_speed = PI/64
export var magwalk_velocity = 100 # pixels/tick
export var magwalk_gravity = 10 # velocity towards surface
export var magwalk_ang_lerp = 0.2
export var jump_impulse = 300
export var gravity_ang_lerp = 0.05
export var dodge_distance = 100
export var maneuver_strength = 10

export var boost_limited = true # boost as double jump
export var boost_number = 3
export var boost_invul_time = 0.3
export var maneuver_enabled = true # move around with WASD

export var hit_area_path : NodePath

# control flags - write from player/ai controller 

var magwalk_dir : Vector2 = Vector2(0,0)
var maneuver_dir : Vector2 = Vector2(0,0)

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
var magwalk_displacement : Vector2
var maneuver_impulse : Vector2
var velocity : Vector2
var last_position : Vector2 = position
var mns_displacement : Vector2

# jumping and movement

var boosts = boost_number
var snap_vector_length = 100

# hitbox / combat

onready var hit_area : Area2D = get_node(hit_area_path)

# signals

signal player_hit()
signal entered_platform(platform, normal)
signal left_platform()
signal jumping()

func _ready():
	
	# test, start by moving down, facing up
	displacement = Vector2(0,40) 
	platform_normal = Vector2(0,-1)
	
	# initial spawn dummy in case floating
	spawn_physics_dummy()
	
	# register hitbox impacts
	assert(hit_area != null)
	hit_area.connect("body_shape_entered", self, "on_hitbox_hit")

func _physics_process(delta):
	
	# update last position, velocity
	velocity = (position - last_position) / delta
	last_position = position
	
	# if floating - 
	# follow dummy, moveandcollide, rotate to gravity
	if !on_platform : 
		
		# move with dummy -

		assert (physics_dummy_spawned)
		
		# add maneuver thrust
		if maneuver_enabled:
			physics_dummy_instance.apply_central_impulse(maneuver_dir.rotated(rotation).normalized() * maneuver_strength);
		
		# set dv to physics dummy velocity
		displacement = physics_dummy_instance.linear_velocity
			
		# if in grav, rotate feet to planet
		rotate_towards_grav()
		
		# move
		var collision =  move_and_collide(displacement * delta, false)
		
		# update rotation from input (?)
		rotation += rotational_velocity
		
		# on collide
		if (collision != null):
			
			# gravityplatforms override
			if (collision.collider.is_in_group("GravityPlatform") || 
				magwalk_enabled && collision.collider.is_in_group("Platform")):
				enter_platform(collision)
	
	# if on platform - 
	# handle snapping, magbooting, jumping
	else: 
		
		# rotate to platform
		rotation = lerp_angle(rotation, platform_normal.angle() + PI/2, magwalk_ang_lerp)
		
		# update snap vector
		var snap_vector = update_snap(snap_vector_length)
		
		# reset velocity
		displacement = Vector2(0,0)
		
		# push towards platform
		displacement += -platform_normal * magwalk_gravity
		
		# add displacement from magwalking
		displacement += platform_normal.tangent() * magwalk_velocity * -magwalk_dir[0]
		
		# for rotating platforms, calculates surface velocity and matches --
		match_surface_velocity()
		
		# update normal --
		update_normal()
		
		# do the move
		move_and_slide_with_snap(displacement, snap_vector, platform_normal, false, 10, 4*PI, false)
	
	# jump - leaves platform and punts the dummy
	if (should_jump):
		if boosts <= 0:
			print("out of boosts")
			should_jump = false
		else:
			if on_platform: 
				leave_platform(500)
				jump(jump_towards, jump_impulse)
			else: jump(jump_towards, jump_impulse, true)
			should_jump = false
			if boost_limited:
				boosts -= 1
			hitbox_invul(boost_invul_time)
		

# PHYSICS_UPDATE HELPER METHODS --

func add_magwalk_direction(direction):
	magwalk_dir += direction
func null_magwalk_direction():
	magwalk_dir = Vector2.ZERO

func add_maneuver_direction(direction):
#	print(rotation)
	maneuver_dir += direction
#	print(maneuver_dir)
	

# if in grav, rotate feet to planet
func rotate_towards_grav():
	
	if in_gravity && gravity_area != null:
		var target : Vector2
		# if point
		if gravity_area.gravity_point:
			target = gravity_area.global_position - position
		# if linear
		else:
			target = gravity_area.gravity_vec
		# rotate
		rotation = lerp_angle(rotation, target.angle() - PI/2, gravity_ang_lerp)

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
	
	# sv = r * radians/sec
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

func update_snap(length) -> Vector2:
	# currently uses direction to center of platform
	# may be an issue for complex shaped platforms
	var snap = (platform.global_position - global_position).normalized() * length
	#$Sprite.global_position = global_position + snap
	return snap

# jump - leaves platform and punts the dummy
func jump(target, vel, reset_vel = false):
	
	print("jumping")
	
	# punt dummy
	
	var impulse = (target - global_position).normalized() * vel
	
	if(reset_vel):
		despawn_physics_dummy()
		spawn_physics_dummy(Vector2.ZERO)
	physics_dummy_instance.apply_central_impulse(impulse)
	
	emit_signal("jumping")

func enter_platform(collision : KinematicCollision2D):
	
	print("entering platform: ", collision.normal)
	platform = collision.collider
	platform_normal = collision.normal
	platform_collision = collision
	
	just_landed = true
	on_platform = true
	
	despawn_physics_dummy()
	
	boosts = boost_number
	
	emit_signal("entered_platform", platform, platform_normal)

func leave_platform(microyeet = 0):
	
	move_and_slide(platform_normal * microyeet, platform_normal)
	print("leaving platform")
	platform_normal = Vector2(0,0)
	on_platform = false
	emit_signal("left_platform")
	
	spawn_physics_dummy()

# PHYSICS DUMMY METHODS --

func spawn_physics_dummy(init_velocity = velocity):
	
	if physics_dummy_instance != null:
		print("physics dummy already exists")
		return
	
	physics_dummy_instance = physics_dummy_preload.instance()
	physics_dummy_instance.position = position
	get_parent().add_child(physics_dummy_instance)
	physics_dummy_spawned = true
	
	physics_dummy_instance.connect("gravity_area_entered", self, "on_dummy_enter_grav")
	physics_dummy_instance.connect("gravity_area_left", self, "on_dummy_leave_grav")
	physics_dummy_instance.apply_central_impulse(init_velocity/physics_dummy_instance.mass)

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

# HITBOX METHODS -- should this be a separate node/helper class?

func on_hitbox_hit(body_id, body, body_shape, area_shape):
	print("BONK")
	emit_signal("player_hit")

# disable hitbox for time given
func hitbox_invul(time : float = 0.0):
	
	hit_area.monitoring = false
	yield(get_tree().create_timer(time), "timeout")
	hit_area.monitoring = true
	
