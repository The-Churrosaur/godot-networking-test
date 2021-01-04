extends RigidBody2D

# movement params

export var magwalk_velocity = 100
export var magwalk_acceleration = 10 # impulse/tick
export var magwalk_deceleration = 10
export var magwalk_rotation = 1 # rad/se
export var magboot_suction = 10 # impulse/tick towards floor

# public control flags, write with character or ai controller

var should_magwalk_left = false
var should_magwalk_right = false

# platform/magboot information

var on_platform = false
var platform = null
var platform_contact_idx = 0
var platform_normal = Vector2(0,0)
var platform_velocity = Vector2(0,0)

func _ready():
	
	# contacts
	connect("body_shape_entered",self, "on_body_shape_entered")
	connect("body_shape_exited", self, "on_body_shape_exited")
	contact_monitor = true;
	contacts_reported = 10;
	
	# test

func on_body_shape_entered(body_id, body, body_shape, local_shape):
	
	print("shape entered")
	
	# handle hitting platform
	if body.is_in_group("Platform"):
		print("hit platform: ", body)
		on_platform = true
		platform = body
		
		# set platform contact to most recent contact
		platform_contact_idx = 0
		
		# kinematic
		mode = MODE_CHARACTER
		print("mode: ", mode)

func on_body_shape_exited(body_id, body, body_shape, local_shape):
	
	# if left platform
	if body.is_in_group("Platform"):
		on_platform = false
		mode = MODE_RIGID
		print("mode: ", mode)

# currently just gets platform normals + velocity
func _integrate_forces(state):
	
	# magwalking --
	
	# get magwalking vector, rotate to
	if on_platform:
		
		# TODO work out multiple collisions
		
		# if multiple bodies colliding, get right one
		#print("multiple bodies colliding")
#		var count = state.get_contact_count()
#		if count > 1:
#			var contact
#			for i in count - 1:
#				contact = state.get_contact_collider_object(i)
#				if contact.is_in_group("Platform"):
#					platform_contact_idx = i
		
		# get platform normal
		platform_normal = state.get_contact_local_normal(platform_contact_idx)
		
		# get platform velocity
		platform_velocity = state.get_contact_collider_velocity_at_position(platform_contact_idx)


func _process(delta):
	
	pass

func _physics_process(delta):
	
	# magwalk --
	
	# rotate to normal
	if (on_platform):
		
		# rotate to normal
		var normal_angle = Vector2(0,-1).angle_to(platform_normal)
		magwalk_rotate(normal_angle)
		
		# apply sticky force
		apply_central_impulse(platform_normal.normalized() * -1 * magboot_suction)
		
		# walk
		if should_magwalk_left:
			try_magwalk(LEFT)
		if should_magwalk_right:
			try_magwalk(RIGHT)
		else:
			magwalk_decel()

# TODO put this in a separate controller node
# handling user inputs
func _input(event):
	
	# magwalk
	if event.is_action_pressed("ui_left", true): # allow echo for other handlers
		should_magwalk_left = true
	if event.is_action_released("ui_left"):
		should_magwalk_left = false
	
	if event.is_action_pressed("ui_right", true):
		should_magwalk_right = true
	if event.is_action_released("ui_right"):
		should_magwalk_right = false

const LEFT = false
const RIGHT = true

func magwalk_rotate(target_rotation):
	
	if target_rotation == rotation:
		angular_velocity = 0
	
	else:
		# set velocity in direction
		var av = magwalk_rotation
		if target_rotation - rotation < 0:
			av = av * -1
		
		angular_velocity = av


func try_magwalk(direction : bool) -> bool:
	
	if on_platform:
		
		var walk_vector : Vector2
		if direction == LEFT:
			walk_vector = Vector2(-magwalk_velocity, 0)
		else:
			walk_vector = Vector2(magwalk_velocity, 0)
		walk_vector = walk_vector.rotated(rotation) # change to char's rotational reference frame
		
		# if relative velocity to platform < max, accelerate
		
		var veldif = linear_velocity - platform_velocity
		if (veldif.length_squared() < magwalk_velocity * magwalk_velocity): 
			apply_central_impulse(walk_vector.normalized() * magwalk_acceleration)
		
		return true
	
	else:
		print("can't walk, not on platform")
		return false

# if walking, don't
func magwalk_decel():
	
	var veldif = linear_velocity - platform_velocity
	if veldif.length_squared() > 0:
		apply_central_impulse(veldif.normalized() * -1 * magwalk_deceleration)


