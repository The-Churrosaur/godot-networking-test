class_name GrappleGun
extends Weapon

export var player_path : NodePath
# force increases with scale by distance^2 beyond length
export var grapple_length = 30.0
export var grapple_impulse = 10.0
export var impulse_scale = 0.00002
export var grapple_max_impulse = 100
export var reel_velocity = 1
export var min_length = 20.0 # cuts off 

onready var player : KinematicCharacter = get_node(player_path)

var player_dummy : RigidBody2D
var grapple_point : Vector2 = Vector2.ZERO
var current_length = grapple_length
var is_grappling = false
var is_reeling = true

# test visuals
onready var sprite = $Sprite

func _ready():
	player.connect("entered_platform", self, "on_player_landed")

func _physics_process(delta):
	if is_grappling: 
		apply_grapple()
		set_sprite()
	else: sprite.visible = false

func apply_grapple(reel = true):
	
	# reel
	if reel: current_length -= reel_velocity
	print(current_length)
	
	var vec = grapple_point - muzzle.global_position
	var dif = vec.length_squared() - current_length
	
	# cutoff
	
	if dif < min_length:
		is_grappling = false
		return
	
	# apply force if beyond current length
	
	if dif > 0:
		var impulse = grapple_impulse * dif * impulse_scale
		if impulse > grapple_max_impulse : impulse = grapple_max_impulse
		player_dummy.apply_central_impulse(vec.normalized() * impulse)
		print(player_dummy.linear_velocity)

func on_bullet_impact(bullet, body):
	.on_bullet_impact(bullet, body)
	print("bullet impact")
	# yank player if on platform
	if player.on_platform:
		print("on platform")
		player.leave_platform()
	
	# get dummy
	player_dummy = player.physics_dummy_instance
	
	current_length = grapple_length
	grapple_point = bullet.global_position
	is_grappling = true

func on_player_landed(platform, normal):
	is_grappling = false

func set_sprite():
	sprite.visible = true
	var half = (grapple_point - muzzle.global_position) / 2
	sprite.global_position = global_position + half
	sprite.global_rotation = half.angle()
	sprite.scale.x = half.length() / 64
	print(sprite.scale.x)
