extends Node2D

export var self_ip = "127.0.0.1"
export var port = 4500

var network_id

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(self_ip, port)
	get_tree().network_peer = peer
	network_id = get_tree().get_network_unique_id()
	
	get_tree().connect("connected_to_server", self, "on_connected")
	get_tree().connect("connection_failed", self, "on_connected_fail")
	
	print("client started")

func on_connected():
	print("client connected to server")

func on_connected_fail():
	print("client failed connection")
