class_name Bullet
extends RigidBody2D

export var impact_impulse = 100000
export var life_time = 5.0
export var activation_time = 0.2 # dead time before bullet activates

signal bullet_removed(bullet, id)

onready var life_timer = $LifeTimer
onready var activation_timer = $ActivationTimer

var temp_collision_layer = collision_layer

func _ready():
	
	# setup contacts for impact, disable to start
	
	contact_monitor = false # set on by activation timer
	contacts_reported = 2
	temp_collision_layer = collision_layer
	collision_layer = 0
	
	connect("body_entered", self, "on_body_entered")
	
	$Particles2D.emitting = true
	
	# setup timers
	
	life_timer.connect("timeout", self, "on_life_timer")
	life_timer.start(life_time)
	
	activation_timer.connect("timeout", self, "on_activation_timer")
	activation_timer.start(activation_time)
	

func on_life_timer():
	destroy()

func on_activation_timer():
	contact_monitor = true
	collision_layer = temp_collision_layer

func on_body_entered(body):
	
	# test with turrets
	if body.is_in_group("TestTurret"):
		body.teleport()
	
	destroy()

func destroy():
	emit_signal("bullet_removed", self, self.name)
	queue_free()
