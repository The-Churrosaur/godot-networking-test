class_name PlayerController
extends Node2D

export var character_path : NodePath
export var weapon_path : NodePath
export var camera_path : NodePath
export var relative_directional_magwalk = false

# the controlees

# watch for circular reference
onready var character : KinematicCharacter = get_node(character_path)
onready var weapon = get_node(weapon_path)
onready var camera : Camera2D = get_node(camera_path)

# camera relative magwalk directions, set when player enters platform
# dynamically resetting is unintuitive
var magwalk_left = Vector2.LEFT
var magwalk_right = Vector2.RIGHT

func _ready():
	
	character.connect("entered_platform", self, "on_player_enter_platform")
	character.connect("left_platform", self, "on_player_left_platform")

func _input(event):
	
	# magwalk and boost
	
	if event.is_action_pressed("ui_left", false): 
		character.add_magwalk_direction(magwalk_left)
		character.add_maneuver_direction(Vector2.LEFT)
	if event.is_action_released("ui_left"):
		character.null_magwalk_direction()
		character.add_maneuver_direction(Vector2.RIGHT)
	
	if event.is_action_pressed("ui_right", false):
		character.add_magwalk_direction(magwalk_right)
		character.add_maneuver_direction(Vector2.RIGHT)
	if event.is_action_released("ui_right"):
		character.null_magwalk_direction()
		character.add_maneuver_direction(Vector2.LEFT)
	
	if event.is_action_pressed("ui_up", false):
		character.add_maneuver_direction(Vector2.UP)
		character.leave_platform(100)
	if event.is_action_released("ui_up"):
		character.add_maneuver_direction(Vector2.DOWN)
	
	if event.is_action_pressed("ui_down", false):
		character.add_maneuver_direction(Vector2.DOWN)
	if event.is_action_released("ui_down"):
		character.add_maneuver_direction(Vector2.UP)
	
	if event.is_action_pressed("ui_rotate_left"):
		character.rotational_velocity = -character.rotational_speed
	if event.is_action_released("ui_rotate_left"):
		character.rotational_velocity = 0
		
	if event.is_action_pressed("ui_rotate_right"):
		character.rotational_velocity = character.rotational_speed
	if event.is_action_released("ui_rotate_right"):
		character.rotational_velocity = 0

	# jump
	
	if event.is_action_pressed("ui_accept"):
		get_parent().get_node("JetLight").visible = true
	if event.is_action_released("ui_accept"):
		character.jump_towards = get_global_mouse_position()
		character.should_jump = true
		get_parent().get_node("JetLight").visible = false
	
	# shoot
	
	if event.is_action_pressed("ui_select"):
		weapon.pull_trigger()
	if event.is_action_released("ui_select"):
		weapon.release_trigger()

func _process(delta):
	
	# update weapon target
	weapon.target = get_global_mouse_position()

func camera_relative_vector(vector : Vector2, player_rot) -> Vector2:
	
	assert(camera != null && character != null)
	
	# camera vector in global reference frame
	var cam_vec = vector.rotated(camera.rotation)
	
	# put camera vector in rotated character reference frame
	var char_vec = cam_vec.rotated(-player_rot)
	
	# project vector onto left/right
	var out = Vector2(char_vec.x, 0).normalized()
	
	print(out)
	return out

func on_player_enter_platform(platform, normal : Vector2):
	
	# set relative magwalk vectors from camera at impact
	if relative_directional_magwalk:
		
		# set projected player rotation as negative tangent to normal
		var player_rot = (normal.tangent() * -1).angle()
		
		magwalk_left = camera_relative_vector(Vector2.LEFT, player_rot)
		magwalk_right = magwalk_left * -1
	
func on_player_left_platform():
	pass
