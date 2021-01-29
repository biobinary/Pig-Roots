extends Node2D

onready var raycast_right : RayCast2D = get_node("WallDetectorRight")
onready var raycast_left : RayCast2D = get_node("WallDetectorLeft")

onready var enemy_main_node : KinematicBody2D = get_node("..")

func _process(delta: float) -> void:
	
	raycast_right.force_raycast_update()
	raycast_left.force_raycast_update()

	if raycast_right.is_colliding():
		enemy_main_node.current_direction = enemy_main_node.DIRECTION.LEFT
		
	elif raycast_left.is_colliding():
		enemy_main_node.current_direction = enemy_main_node.DIRECTION.RIGHT
		
	if enemy_main_node.current_direction == enemy_main_node.DIRECTION.RIGHT:
		raycast_left.enabled = false
		raycast_right.enabled = true
	else:
		raycast_right.enabled = false
		raycast_left.enabled = true
