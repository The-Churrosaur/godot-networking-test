extends Node2D


export var hex_grid_path : NodePath

onready var hex_grid = get_node(hex_grid_path)
onready var line = $Line2D

var current_hex_coord = Vector2(0,0)
var movement_vector = Vector2(0,0)

func _ready():
	move_to_current_hex()
	
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

func _input(event):
	
	if event.is_action_released("ui_right"):
		current_hex_coord = current_hex_coord + Vector2.RIGHT
		move_to_current_hex()
	
	if event.is_action_released("ui_down"):
		current_hex_coord = current_hex_coord + Vector2.DOWN
		move_to_current_hex()
	
	if event.is_action_released("ui_left"):
		current_hex_coord = current_hex_coord + Vector2.LEFT
		move_to_current_hex()
	
	if event.is_action_released("ui_up"):
		current_hex_coord = current_hex_coord + Vector2.UP
		move_to_current_hex()
	
	if event.is_action_released("ui_lmb"):
		var target = hex_grid.get_hex_from_pos(get_global_mouse_position())
		movement_vector = target - current_hex_coord
		line.set_point_position(1, line.to_local(hex_grid.get_hex_pos(current_hex_coord + movement_vector)))
	
	if event.is_action_released("ui_accept"):
		current_hex_coord += movement_vector
		move_to_current_hex()

func _process(delta):
	
	var mouse_hex = hex_grid.get_hex_from_pos(get_global_mouse_position())
	line.set_point_position(2, line.to_local(hex_grid.get_hex_pos(mouse_hex)))

func move_to_current_hex():
	position = hex_grid.get_hex_pos(current_hex_coord)
