class_name EnemyShotgunController
extends EnemyController

export var shoot_distance = 400

func process_logic():
	
	# basic per-frame logic
	if target != null:
		
		# aim towards target
		weapon.target = target.global_position
		
		# face towards target
#		if !character.on_platform:
#			character.rotation = PI + (target.global_position - character.global_position).angle()
		
		lead_target()
		
		var distance_sq = (target.global_position - character.global_position).length_squared()
		if !target_obstructed(target) && distance_sq < shoot_distance * shoot_distance:
			weapon.pull_trigger()
		else:
			weapon.release_trigger()
