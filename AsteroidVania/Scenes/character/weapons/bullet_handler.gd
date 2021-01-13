extends Node2D

# global handler of guns and bullets

# the base level node
# TODO make level loader singleton
var level setget set_level, get_level

# currently dicts, can think about data structures if becomes issue
# registers each by id -> node, currently passing name as id
var weapons = {}
var bullets = {}

func _ready():
	pass

func register_gun(weapon, id):
	
	print("weapon registered: ", weapon)
	weapons[weapon.name] = weapon
	weapon.connect("bullet_spawned", self, "on_bullet_spawned")

func on_bullet_spawned(weapon, bullet, id):
	
	#print("handler: bullet spawned: ", bullet)
	bullets[id] = bullet
	bullet.connect("bullet_removed", self, "on_bullet_removed")
	level.add_child(bullet)

func on_bullet_removed(bullet, id):
	bullets.erase(id)

func set_level(lev):
	
	level = lev
	# clear guns and bullets on new level
	print("handler cleared")
	clear_handler()

func get_level():
	return level

func clear_handler():
	weapons.clear()
	bullets.clear()
