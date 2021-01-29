# Credits :
# Sound Effect => https://soundcloud.com/noshades
# Art Assets => pixelfrog-store

extends Node

# Player Node and Node Path
export(NodePath) var player_node_path : NodePath
var main_player_node : KinematicBody2D
# -----------------------------------------------

onready var transition_animation : AnimationPlayer = get_node("TransitionsLayer/AnimationPlayer")

onready var game_tween : Tween = get_node("GameTween")
onready var game_ui : Control = get_node("GameUI/GameUserInterface")

# World Environments Scene
var world_environments : Array = [
	preload("res://src/MainWorld/WorldObjectsOne.tscn"),
	preload("res://src/MainWorld/WorldObjectsTwo.tscn"),
	preload("res://src/MainWorld/WorldObjectsThree.tscn"),
	preload("res://src/MainWorld/WorldObjectsFour.tscn")
]
var current_environments : int = 1
# ---------------------------------------------------------

# Private Property
var _current_world_node : Node2D = null
var _is_character_body_froze : bool = false

var _is_paused_exited : bool = false
var _is_paused_timeout : bool = false

var _is_paused : bool = true
# -------------------------------------------

# Enemy Property
onready var enemy_node_holder : Node2D = get_node("EnemyNode")
var _enemy_effect : PackedScene = preload("res://src/Enemy/Effect/TeleportEffect.tscn")
var enemy_spawn_position : PoolVector2Array = PoolVector2Array()
# ---------------------------------------------------------------------------------------

func _ready() -> void:
	
	# Hide The Mouse Cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# -------------------------------------------
	
	GlobalGameDataScript.connect("switch_world", self, "_do_switch_to_new_world")
	GlobalGameDataScript.connect("timeout", self, "_do_time_is_done")
	
	yield(transition_animation, "animation_finished")
	get_tree().paused = false
	_is_paused = false
	
	# Get The Player Node
	if player_node_path:
		main_player_node = get_node(player_node_path)
	# -------------------------------------------------

	var get_current_enemy_spawn_position : Node2D = get_node("WorldObjects").get_node("EnemySpawnLocation")
	
	_do_add_new_enemy_spawn_position(get_current_enemy_spawn_position)
	_do_add_enemy()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_cancel") and not _is_paused:
		
		get_tree().paused = true
		_is_paused_exited = true
		_is_paused = true
		
		transition_animation.play_backwards("CoverUp")

func _do_change_environment(index : int) -> void:
	
	var new_position : Vector2 = Vector2(-712, 64)
	
	for child in get_children():
		if child.is_in_group("WorldEnvironment"):
			_current_world_node = child
			break

	var new_world_environment : Node2D = world_environments[index].instance()
	
	self.add_child(new_world_environment)
	
	new_world_environment.position = Vector2(712, 64)
	var respawn_position : Vector2 = new_world_environment.get_node("SpawnLocation").position + Vector2(0, 64)
	
	_do_add_new_enemy_spawn_position(new_world_environment.get_node("EnemySpawnLocation"))

	# Positioning The World Object
	game_tween.interpolate_property(
		_current_world_node, "position", _current_world_node.position, new_position, 
		1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	game_tween.interpolate_property(
		new_world_environment, "position", new_world_environment.position, _current_world_node.position, 
		1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0
	)
	# ---------------------------------------------------------------------------------------------------
	
	# Interpolate Character Scale With Tween
	game_tween.interpolate_property(
		main_player_node, "scale", Vector2.ONE, Vector2.ONE * 1.5, 
		1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	game_tween.interpolate_property(
		main_player_node, "scale", Vector2.ONE * 1.5, Vector2.ONE, 
		1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0
	) 
	# ---------------------------------------------------------------
	
	game_tween.interpolate_property(
		main_player_node, "position", main_player_node.position, respawn_position,
		1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1.0
	)
	
	game_tween.start()

func _on_GameTween_tween_all_completed() -> void:
	
	if _current_world_node:
		_current_world_node.queue_free()
		_current_world_node = null

	if _is_character_body_froze:
		main_player_node.do_freeze_body(false)
		_is_character_body_froze = false

	game_ui.do_set_pause_timer(false)
	_do_add_enemy()

func _do_add_enemy() -> void:
	
	var index : int = 0
	var values : PoolIntArray = PoolIntArray(GlobalGameDataScript.questions_lst.values())
	
	while enemy_spawn_position.size() != 0:
		
		var enemy_effect : Particles2D = _enemy_effect.instance()
		
		enemy_effect.is_spawn_enemy = true
		enemy_effect.number = values[index]
		
		enemy_node_holder.add_child(enemy_effect)
		
		enemy_effect.position = enemy_spawn_position[0]
		enemy_spawn_position.remove(0)
		
		index += 1

func _do_switch_to_new_world() -> void:
	
	_is_character_body_froze = true

	current_environments += 1
	
	if current_environments == world_environments.size():
			current_environments = 0
		
	main_player_node.do_freeze_body(true)
	game_ui.do_set_pause_timer(true)
	
	_do_change_environment(current_environments)

# Get All Spawn Location
func _do_add_new_enemy_spawn_position(node : Node2D) -> void:
	
	for position_2D in node.get_children():
		GlobalGameDataScript.do_add_new_question()
		enemy_spawn_position.append(position_2D.position + Vector2(0, 64))
		
	GlobalGameDataScript.do_pick_random_question()
# ------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	if _is_paused_exited:
		GlobalGameDataScript.do_reset_data()
		get_tree().change_scene("res://src/UserInterface/MainMenu.tscn")
		
	elif _is_paused_timeout:
		get_tree().change_scene("res://src/UserInterface/TimeoutMenu.tscn")

func _do_time_is_done() -> void:
	
	if not _is_paused:
		
		get_tree().paused = true
		_is_paused_timeout = true
		_is_paused = true
		
		transition_animation.play_backwards("CoverUp")
