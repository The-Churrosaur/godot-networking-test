class_name PhysicsPlatform
extends KinematicBody2D

export var colliders_group = "PhysicsPlatformCollider"
export var initial_velocity : Vector2
export var initial_velocity_angular : float

onready var phyics_dummy_preload = preload("res://Scenes/environment/physics_platform_dummy.tscn")

var physics_dummy_instance : RigidBody2D = null
var colliders = []
var first_tick = true

func _ready():
	
	# add all named colliders to array
	for node in get_children():
		if node.is_in_group(colliders_group):
			colliders.append(node)

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
	
	# startup dummy
	
	physics_dummy_instance = phyics_dummy_preload.instance()
	physics_dummy_instance.position = position
	get_parent().add_child(physics_dummy_instance)
	
	# setup dummy colliders from array
	
	for node in colliders:
		if !node is CollisionShape2D:
			print ("junk in collider array")
			return
		var instance_collider = CollisionShape2D.new()
		instance_collider.shape = node.shape
		physics_dummy_instance.add_child(instance_collider)
	
	# feed dummy initial params
	
	physics_dummy_instance.linear_velocity = initial_velocity
	physics_dummy_instance.angular_velocity = initial_velocity_angular

