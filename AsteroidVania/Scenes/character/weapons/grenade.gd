class_name Grenade
extends Bullet

export var shrapnel_gun_path : NodePath = "ShrapnelGun"
export var impact_grenade = false # else explodes on lifetime

onready var shrapnel_gun = get_node(shrapnel_gun_path)

func _ready():
	pass

func impact(body):
	if impact_grenade:
		explode()
		.impact(body)
	# else pass, bounce etc.

func on_life_timer():
	explode()
	.on_life_timer()

func explode():
	print("pof")
	shrapnel_gun.pull_trigger()
	.destroy()
