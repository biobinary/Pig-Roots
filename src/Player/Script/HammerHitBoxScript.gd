extends Area2D

onready var player_main_node : KinematicBody2D = get_parent()

func _on_HammerHitBox_body_entered(body: Node) -> void:
	
	if not body.is_been_hit:
		GlobalGameDataScript.do_check_question(body.number)
		body.do_enemy_death(player_main_node._player_horizontal_direction)
