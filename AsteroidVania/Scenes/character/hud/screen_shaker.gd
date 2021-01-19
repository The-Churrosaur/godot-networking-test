class_name ScreenShaker
extends Node

# this is kind of bad, use noise or smth

export var camera_path : NodePath = "../"
export var shake_lerp = 0.4

onready var camera : Camera2D = get_node(camera_path)
onready var frequency_timer : Timer = $FrequencyTimer
onready var tween : Tween = $Tween
onready var rand : RandomNumberGenerator = RandomNumberGenerator.new()

# reads flag then lerps between amp target
# amp target resets on freq timer
var shaking_rot = false
var shaking_pos = false

var rot_amp_target = 0.0
var pos_amp_center = Vector2(0,0)
var pos_amp_target = Vector2(0,0)

func _ready():
	frequency_timer.connect("timeout", self, "on_frequency")

func _physics_process(delta):
	shake_camera(shaking_rot, shaking_pos)
	

func shake_camera(rot, pos):
	if camera == null: return
	
	if rot:
		camera.rotation = lerp_angle(camera.rotation, rot_amp_target, shake_lerp)
	if pos:
		camera.position = lerp(camera.position, pos_amp_target, shake_lerp)

func shake_rot(amplitude, frequency, duration):
	
	print("shaking rot")
	rot_amp_target = amplitude
	frequency_timer.start(frequency)
	
	shaking_rot = true
	yield(get_tree().create_timer(duration), "timeout")
	shaking_rot = false

func shake_pos(amplitude, frequency, duration):
	
	print("shaking pos")
	pos_amp_target = Vector2(amplitude, amplitude)
	frequency_timer.start(frequency)
	
	shaking_pos = true
	yield(get_tree().create_timer(duration), "timeout")
	shaking_pos = false
	

func on_frequency():
	rot_amp_target *= -1
	pos_amp_target *= -1
