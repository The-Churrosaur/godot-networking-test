extends Label

export var player_path : NodePath
onready var player = get_node(player_path)

var hits = 0

func _ready():
	player.connect("player_hit", self, "on_player_hit")

func on_player_hit():
	hits += 1
	text = str(hits)
