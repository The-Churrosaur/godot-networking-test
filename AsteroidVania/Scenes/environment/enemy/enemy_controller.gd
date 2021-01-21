class_name EnemyController
extends Node

export var character_path : NodePath = "../KinematicCharacter"
export var weapon_path : NodePath = "../KinematicCharacter/Weapon" # temp, work out a better way
export var anim_path : NodePath = "../KinematicCharacter/Rig/AnimationPlayer"
export var target_manager_path : NodePath = "../../TargetManager"
export var detection_area_path : NodePath = "../KinematicCharacter/DetectionArea"
export var health_path : NodePath = "../CharacterHealth"

export var teleport_distance = 2000

onready var character = get_node(character_path)
onready var weapon = get_node(weapon_path)
onready var animator : AnimationPlayer = get_node(anim_path)
onready var target_manager = get_node(target_manager_path)
onready var detection_area : Area2D = get_node(detection_area_path)
onready var health = get_node(health_path)

# logic
# ai ponders action every firing
onready var decision_timer = $DecisionTimer

# ai
var target = null
var rng = RandomNumberGenerator.new()

func _ready():
	
	# connect to detection area
	detection_area.connect("body_entered", self, "on_area_detected")
	detection_area.connect("body_exited", self, "on_area_lost")
	
	# connect to player
	character.connect("player_hit", self, "on_player_hit")
	character.connect("platform_entered", self, "char_landed")
	
	# decision timer
	decision_timer.connect("timeout", self, "on_decision_timer")
	decision_timer.start(decision_timer.wait_time)
	
	# health
	health.connect("health_zero", self, "on_health_zero")

func _process(delta):
	
	# basic logic
	if target != null:
		
		# aim towards target
		weapon.target = target.global_position
		
		# face towards target
#		if !character.on_platform:
#			character.rotation = PI + (target.global_position - character.global_position).angle()
		
		# lead target
		
		var shot_time = (target.position - character.position).length() / weapon.impulse
		var displacement = (target.velocity * shot_time)
		
		var projected = target.position + displacement
		weapon.target = projected

func on_area_detected(body):
	
	# could check this in a simpler way 
	# idk might be good to log all targetters
	if body == target_manager.get_target_node(target_manager.PLAYER):
		acquire_target(body)
		weapon.pull_trigger()

func on_area_lost(body):
	
	if body == target:
		acquire_target(body)
		weapon.release_trigger()

func acquire_target(body):
	print("target acquired")
	target = body
	jump_towards(target)

func on_player_hit(body):
	
	if body.is_in_group("Bullet"):
		print("ENEMY HIT")
		#teleport()
		health.change_health(-1)

func teleport():
	print("teleporting")
	rng.randomize()
	var x = rng.randf_range(-teleport_distance,teleport_distance)
	var y = rng.randf_range(-teleport_distance,teleport_distance)
	character.queue_teleport(Vector2(x,y))


func char_landed(platform, normal):
	pass

func jump_towards(target):
	
	character.jump_towards = target.global_position
	character.should_jump = true

func on_health_zero():
	teleport()
	health.change_health(5)

# TEST AI LOGIC --

func on_decision_timer():
	
	if target != null:
		
		if character.on_platform:
			
			# walk
			character.magwalk_dir = magwalk_towards_target()
		else:
			character.rotation = PI + (target.global_position - character.global_position).angle()
		
		if (target.global_position - character.global_position).length_squared() > 500 * 500:
			jump_towards(target)

func magwalk_towards_target() -> Vector2:
	
	# magwalk closest route to player
	# target in character reference frame
	var tar = target.global_position - character.global_position
	var char_tar = tar.rotated(-character.rotation)
	
	# project onto l/r
	var dir = Vector2(char_tar.x, 0).normalized()
	
	return dir
