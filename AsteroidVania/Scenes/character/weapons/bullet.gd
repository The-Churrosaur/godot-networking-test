class_name Bullet
extends RigidBody2D

signal bullet_removed(bullet, id)

func _ready():
	# setup contacts for impact
	contact_monitor = true
	contacts_reported = 2
	connect("body_entered", self, "on_body_entered")
	
	$Particles2D.emitting = true

func on_body_entered(body):
	
	# temp, just delete
	queue_free()
	emit_signal("bullet_removed")
