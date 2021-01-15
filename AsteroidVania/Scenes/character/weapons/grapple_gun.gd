class_name GrappleGun
extends Weapon

# force increases with scale by distance^2 beyond length
export var grapple_length = 30.0
export var grapple_impulse = 10.0
export var impulse_scale = 0.02
export var grapple_max_impulse = 20
export var reel_velocity = 1
export var min_length = 20.0 # cuts off 
export var player_path : NodePath

onready var player = shooter # notation, shooter defined as kinematiccharacter in weapon
var player_dummy : RigidBody2D
var grapple_body : PhysicsBody2D
var grapple_point : Vector2 = Vector2.ZERO
var grapple_offset : Vector2 = Vector2.ZERO # relative vector from grapple body
var rope_length = grapple_length
var is_grappling = false
var is_reeling = true

# test visuals
onready var sprite = $Sprite

func _ready():
	player.connect("entered_platform", self, "on_player_landed")

func _physics_process(delta):
	if is_grappling: 
		apply_grapple(delta)
		set_sprite()
	else: 
		sprite.visible = false
		$Sprite2.visible = false

func apply_grapple(reel = true, delta = 1.0):
	
	# reel
	if reel: rope_length -= reel_velocity
	print(rope_length)
	
	# update grapple_point from body
	
	# if freed
	if !weakref(grapple_body).get_ref():
		grapple_body = null
		end_grapple()
		return
	# if moving
	elif grapple_body is RigidBody2D:
		grapple_point = grapple_body.position + grapple_offset.rotated(grapple_body.rotation)
	
	var vec = grapple_point - muzzle.global_position
	var dif = vec.length() - rope_length
	
	# cutoff
	if dif < min_length:
		end_grapple()
		return
	
	# check status of body
	if !weakref(player_dummy).get_ref() || player_dummy == null:
		end_grapple()
		return
	
	# apply force if beyond current length
	
	if dif > 0:
		var impulse = grapple_impulse * dif * impulse_scale
		if impulse > grapple_max_impulse : impulse = grapple_max_impulse
		player_dummy.apply_central_impulse(vec.normalized() * impulse)

func end_grapple():
	is_grappling = false

func on_bullet_impact(bullet, body):
	.on_bullet_impact(bullet, body)
	
	# yank player if on platform
	if player.on_platform:
		player.leave_platform()
	
	# get dummy, impacting body
	player_dummy = player.physics_dummy_instance
	grapple_body = body
	
	rope_length = grapple_length
	grapple_point = bullet.global_position
	grapple_offset = (grapple_point - body.position).rotated(-body.rotation)
	is_grappling = true

# also cut grapple if hitting platform
func on_player_landed(platform, normal):
	end_grapple()

func set_sprite():
	sprite.visible = true
	var half = (grapple_point - muzzle.global_position) / 2
	sprite.global_position = global_position + half
	sprite.global_rotation = half.angle()
	sprite.scale.x = half.length() / 64
	
	$Sprite2.visible = true
	$Sprite2.global_position = grapple_point
