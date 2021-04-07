extends Node2D

export var ip = ""
export var port : int
export var max_players = 10

var network_id
var clients = []

func _ready():
	pass

func setup_peer(port, server = true, ip = ""):
	
	if get_tree().network_peer != null:
		print("peer already set")
		return
	
	var peer = NetworkedMultiplayerENet.new()
	if server:
		peer.create_server(port, max_players)
		print("server starting")
	else:
		peer.create_client(ip, port)
		print("client starting")
	get_tree().network_peer = peer
	network_id = get_tree().get_network_unique_id()
	
	# connect signals
	get_tree().connect("network_peer_connected", self, "on_player_connected")
	get_tree().connect("connected_to_server", self, "on_connected")
	get_tree().connect("connection_failed", self, "on_connected_fail")

# server signals =========

func on_player_connected(id):
	print("server: player connected: ", id)
	clients.append(id)

func on_connected():
	print("peer: connected to server: ", network_id)

func on_connected_fail():
	print("peer: failed connection: ", network_id)

# test funcs ==========

remotesync func print_peers():
	print(get_tree().get_network_unique_id(), " clients: ", clients)
