extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var magwalk_velocity = 100 # pixels/tick
export var magwalk_gravity = 10 # velocity towards surface
export var magwalk_ang_lerp = 0.2
export var jump_velocity = 100
export var gravity_ang_lerp = 0.05

var surface
var downVector
var impulseFromSurface
var impulseFromSelf


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
	
func _physics_process(delta):
	
_integrate_forces(state):
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
