class_name Bullet
extends RigidBody2D

export var impact_impulse = 100000
export var life_time = 5.0
export var activation_time = 0.2 # dead time before bullet activates
export var damage = 1

signal bullet_removed(bullet, id)
signal bullet_impacted(bullet, body)

onready var life_timer = $LifeTimer
onready var activation_timer = $ActivationTimer

var temp_collision_layer = collision_layer
var temp_collision_mask = collision_mask

func _ready():
	
	# setup contacts for impact, disable to start
	
	contact_monitor = false # set on by activation timer
	contacts_reported = 2

	collision_layer = 0
	collision_mask = 0
	
	connect("body_entered", self, "on_body_entered")
	
	$Particles2D.emitting = true
	
	# setup timers
	
	life_timer.connect("timeout", self, "on_life_timer")
	life_timer.start(life_time)
	
	yield(get_tree().create_timer(activation_time), "timeout")
	on_activation_timer()
	

func on_life_timer():
	destroy()

func on_activation_timer():
	
	contact_monitor = true
	collision_layer = temp_collision_layer
	collision_mask = temp_collision_mask

func on_body_entered(body):
	
	# test with turrets
	if body.is_in_group("TestTurret"):
		body.teleport()
	
	impact(body)

func impact(body):
	emit_signal("bullet_impacted", self, body)
	destroy()

func destroy():
	emit_signal("bullet_removed", self, self.name)
	queue_free()
