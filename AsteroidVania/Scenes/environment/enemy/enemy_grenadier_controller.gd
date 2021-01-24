class_name EnemyGrenadierController
extends EnemyShotgunController

func on_decision_timer():
	
	if target != null:
		
		if character.on_platform:
			
			# walk away
			character.magwalk_dir = magwalk_towards_target() * -1
		else:
			character.rotation = PI + (target.global_position - character.global_position).angle()
		
		if (target.global_position - character.global_position).length_squared() > 300 * 300:
			jump_towards(target.global_position)

func on_area_detected(body):
	
	# could check this in a simpler way 
	# idk might be good to log all targetters
	if body == target_manager.get_target_node(target_manager.PLAYER):
		acquire_target(body)
		# jump away from target
		var away = target.global_position - character.global_position * -1
		jump_towards(away)

func on_area_lost(body):
	
	if body == target:
		acquire_target(body)
