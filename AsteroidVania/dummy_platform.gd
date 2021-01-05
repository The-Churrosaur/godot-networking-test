class_name DummyPlatform
extends KinematicBody2D

onready var collider = $CollisionShape2D
onready var phyics_dummy_preload = preload("res://platform_physics_dummy.tscn")

var physics_dummy_instance : RigidBody2D = null
var first_tick = true

func _physics_process(delta):
	
	# if first tick, spawn physics dummy
	# it has to be this way for some reason TODO
	
	if first_tick:
		setup_dummy()
		first_tick = false
	
	# parrot physics dummy --
	
	if physics_dummy_instance == null:
		print("dummy is null!")
		return
	
	rotation = physics_dummy_instance.rotation
	position = lerp(position, physics_dummy_instance.position, 0.9)
	# not moveandcollide so it doesn't interact with player
	
func setup_dummy():
	
	physics_dummy_instance = phyics_dummy_preload.instance()
	physics_dummy_instance.position = position
	get_parent().add_child(physics_dummy_instance)
	
	var instance_collider = CollisionShape2D.new()
	instance_collider.shape = collider.shape
	physics_dummy_instance.add_child(instance_collider)

