extends Sprite

# temp hitindicator, use animations for this

onready var player = get_parent()

func _ready():
	player.connect("player_hit", self, "on_hit")
	visible = false

func on_hit(body):
	visible = true
	yield(get_tree().create_timer(0.2), "timeout")
	visible = false
