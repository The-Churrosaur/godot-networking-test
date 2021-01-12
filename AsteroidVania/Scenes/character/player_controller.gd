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
	
	if event.is_action_pressed("ui_left", true): # allow echo for other handlers
		character.should_magwalk_left = true
		character.should_boost = true
		character.boost_dir = Vector2(-1,0)
	if event.is_action_released("ui_left"):
		character.should_magwalk_left = false
	
	if event.is_action_pressed("ui_right", true):
		character.should_magwalk_right = true
		character.should_boost = true
		character.boost_dir = Vector2(1,0)
	if event.is_action_released("ui_right"):
		character.should_magwalk_right = false
	
	if event.is_action_pressed("ui_up"):
		character.should_boost = true
		character.boost_dir = Vector2(0,-1)
	
	if event.is_action_pressed("ui_down"):
		character.should_boost = true
		character.boost_dir = Vector2(0,1)
	
	# jump
	
	if event.is_action_pressed("ui_accept"):
		get_parent().get_node("JetLight").visible = true
	if event.is_action_released("ui_accept"):
		character.should_jump = true
		character.jump_towards = get_global_mouse_position()
		get_parent().get_node("JetLight").visible = false
	
	# shoot
	if event.is_action_pressed("ui_select"):
		weapon.pull_trigger()
	if event.is_action_released("ui_select"):
		weapon.release_trigger()

func _process(delta):
	
	# update weapon target
	weapon.target = get_global_mouse_position()
