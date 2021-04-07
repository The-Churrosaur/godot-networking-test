extends Node2D


onready var hexgrid = $HexGrid

func _ready():
	var hex = load("res://Hex/Hex.tscn").instance()
	
	for i in 10:
		for j in 10:
			hex = load("res://Hex/Hex.tscn").instance()
			hex.coord = Vector2(i,j)
			hexgrid.place_hex(hex)
			add_child(hex)
			
			var rand = RandomNumberGenerator.new()
			rand.randomize()
			var f = rand.randi_range(0,40)
			hex.get_node("Sprite").frame = f
