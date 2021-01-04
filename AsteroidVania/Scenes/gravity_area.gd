class_name GravityArea
extends Area2D

# when body enters/exits, if dummy warn it

func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")

func on_body_entered(body):
	if body.is_in_group("Dummy"):
		body.area_trigger_enter(self)

func on_body_exited(body):
	if body.is_in_group("Dummy"):
		body.area_trigger_exit(self)
