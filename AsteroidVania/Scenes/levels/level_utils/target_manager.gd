class_name TargetManager
extends Node2D

enum {PLAYER, ENEMY}

export var player_base_path : NodePath

onready var player_base = get_node(player_base_path)
onready var player = player_base.player

func get_target_node(type):
	if type == PLAYER:
		return player_base.player
