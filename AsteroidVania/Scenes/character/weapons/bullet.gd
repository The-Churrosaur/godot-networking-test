class_name Bullet
extends RigidBody2D

export var impact_impulse = 100000
export var life_time = 5.0

signal bullet_removed(bullet, id)

onready var life_timer = $LifeTimer

func _ready():
	
	# setup contacts for impact
	
	contact_monitor = true
	contacts_reported = 2
	connect("body_entered", self, "on_body_entered")
	
	$Particles2D.emitting = true
	
	# setup timers
	
	life_timer.connect("timeout", self, "on_life_timer")
	life_timer.start(life_time)
	

func on_life_timer():
	destroy()

func on_body_entered(body):
	
	# test with turrets
	if body.is_in_group("TestTurret"):
		body.teleport()
	
	destroy()

func destroy():
	emit_signal("bullet_removed", self, self.name)
	queue_free()
