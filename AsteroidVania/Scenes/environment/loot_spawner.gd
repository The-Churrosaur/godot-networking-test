class_name LootSpawner
extends Node2D

export var loot_scene : PackedScene = preload("res://Scenes/environment/health_pickup.tscn")

func spawn_loot(pos = global_position):
	var loot = loot_scene.instance()
	loot.global_position = pos
	# use level singleton later
	get_tree().root.add_child(loot)
