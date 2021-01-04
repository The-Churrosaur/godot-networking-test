extends RigidBody2D

signal gravity_area_entered(area)
signal gravity_area_left(area)

func _ready():
	pass

# triggered by gravityArea when entered / exited 

func area_trigger_enter(area):
	print("dummy triggered")
	emit_signal("gravity_area_entered", area)

func area_trigger_exit(area):
	print("dummy triggered leave")
	emit_signal("gravity_area_left", area)
