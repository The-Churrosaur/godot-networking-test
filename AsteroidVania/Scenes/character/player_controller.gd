class_name PlayerController
extends Node2D

export var character_path : NodePath
export var anim_path : NodePath = "../KinematicCharacter/Rig/AnimationPlayer"
export var weapon_path : NodePath
export var grapple_path : NodePath

export var camera_path : NodePath
export var hud_path : NodePath = "../Hud"
export var health_path : NodePath = "../CharacterHealth"
export var health_bar_path : NodePath = "../Hud/Hud/HealthBar"

export var relative_directional_magwalk = false
export var mouse_camera_rotation = false

# the controlees

# watch for circular reference
onready var character : KinematicCharacter = get_node(character_path)
onready var animator : AnimationPlayer = get_node(anim_path)
onready var weapon = get_node(weapon_path)
onready var grapple = get_node(grapple_path)

onready var camera : Camera2D = get_node(camera_path)
onready var hud : CanvasLayer = get_node(hud_path)
onready var health = get_node(health_path)
onready var health_bar = get_node(health_bar_path)

# camera relative magwalk directions, set when player enters platform
# dynamically resetting is unintuitive
var magwalk_left = Vector2.LEFT
var magwalk_right = Vector2.RIGHT

func _ready():
	
	# character connections
	character.connect("entered_platform", self, "on_player_enter_platform")
	character.connect("left_platform", self, "on_player_left_platform")
	character.connect("player_hit", self, "on_player_hit")

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
		character.get_node("JetLight").visible = true
	if event.is_action_released("ui_accept"):
		character.jump_towards = get_global_mouse_position()
		character.should_jump = true
		character.get_node("JetLight").visible = false
	
	
	# shoot
	
	if event.is_action_pressed("ui_select"):
		weapon.pull_trigger()
	if event.is_action_released("ui_select"):
		weapon.release_trigger()
	
	if event.is_action_pressed("ui_alt_select"):
		grapple.pull_trigger()
	if event.is_action_released("ui_alt_select"):
		grapple.release_trigger()

func _process(delta):
	
	# update weapon target
	weapon.target = get_global_mouse_position()
	grapple.target = get_global_mouse_position()
	
	if !character.on_platform && mouse_camera_rotation:
		var view = hud.get_viewport()
		character.rotation = (view.get_mouse_position() - view.size / 2).angle()
	

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

func on_player_hit(body):
	
	# if shot
	if body.is_in_group("Bullet"):
		health.change_health(-1)
		health_bar.remove_health(1)
	
	# if medpack
	if body.is_in_group("Pickup"):
		body.collect_pickup(character)
		health.change_health(1)
		health_bar.add_health(1)
