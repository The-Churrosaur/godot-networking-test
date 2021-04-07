extends Control

onready var client_button = $CenterContainer/MarginContainer/HBoxContainer/ClientButton
onready var server_button = $CenterContainer/MarginContainer/HBoxContainer/ServerButton
onready var port_line = $CenterContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/LineEditPort
onready var ip_line = $CenterContainer/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/LineEditIP

onready var peer_base = $PeerBase

var ip = ""
var port = null

func _ready():
	client_button.connect("button_down", self, "client_pressed")
	server_button.connect("button_down", self, "server_pressed")

func client_pressed():
	ip = ip_line.text
	port = int(port_line.text)
	peer_base.ip = ip
	peer_base.port = port
	
	peer_base.setup_peer(port, false, ip)
	change_scene_to_peerbase()

func server_pressed():
	port = int(port_line.text)
	peer_base.ip = ip
	peer_base.port = port
	
	peer_base.setup_peer(port)
	change_scene_to_peerbase()

func change_scene_to_peerbase():
	remove_child(peer_base)
	peer_base.owner = null
	get_tree().get_root().add_child(peer_base)
	queue_free()

