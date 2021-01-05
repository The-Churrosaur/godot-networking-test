class_name PlayerController
extends Node2D

# the controlee
var character : PhysicsBody2D

func _ready():
	character = get_parent()

func _input(event):
	
	# magwalk
	if event.is_action_pressed("ui_left", true): # allow echo for other handlers
		character.should_magwalk_left = true
	if event.is_action_released("ui_left"):
		character.should_magwalk_left = false
	
	if event.is_action_pressed("ui_right", true):
		character.should_magwalk_right = true
	if event.is_action_released("ui_right"):
		character.should_magwalk_right = false
	
	# jump
	if event.is_action_released("ui_accept"):
		character.should_jump = true
		character.jump_towards = get_global_mouse_position()
