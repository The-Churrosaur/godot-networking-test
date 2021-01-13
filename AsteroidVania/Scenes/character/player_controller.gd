class_name PlayerController
extends Node2D



export var character_path : NodePath
export var weapon_path : NodePath

# the controlee
var character : PhysicsBody2D
var weapon

func _ready():
	character = get_node(character_path)
	weapon = get_node(weapon_path)

func _input(event):
	
	# magwalk and boost
	
	if event.is_action_pressed("ui_left", false): # allow echo for other handlers
		character.add_magwalk_direction(Vector2.LEFT)
		character.add_maneuver_direction(Vector2.LEFT)
	if event.is_action_released("ui_left"):
		character.add_magwalk_direction(Vector2.RIGHT)
		character.add_maneuver_direction(Vector2.RIGHT)
	
	if event.is_action_pressed("ui_right", false):
		character.add_magwalk_direction(Vector2.RIGHT)
		character.add_maneuver_direction(Vector2.RIGHT)
	if event.is_action_released("ui_right"):
		character.add_magwalk_direction(Vector2.LEFT)
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
