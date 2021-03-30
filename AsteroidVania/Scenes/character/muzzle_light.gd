extends Light2D

export var weapon_path : NodePath
export var flash_time = 0.05

onready var weapon = get_node(weapon_path)

func _ready():
	weapon.connect("bullet_spawned", self, "flash")

func flash(gun, projectile, projectile_name):
	enabled = true
	print("flash")
	yield(get_tree().create_timer(flash_time), "timeout")
	enabled = false
