extends Control

onready var button = $CenterContainer/VBoxContainer/Button
onready var line = $CenterContainer/VBoxContainer/LineEdit

func _ready():
	button.connect("button_down", self, "on_button")
	line.connect("text_entered", self, "on_line_enter")

func on_button():
	var id = get_tree().get_network_unique_id()
	rpc("ping", id)

remotesync func ping(id):
	print("pinged by: ", id)
	rpc("chat", get_node("../../").clients, get_tree().get_network_unique_id())

func on_line_enter(text):
	var id = get_tree().get_network_unique_id()
	rpc("chat", text, id)

remotesync func chat(text, id):
	print(id, " says: ", text)
