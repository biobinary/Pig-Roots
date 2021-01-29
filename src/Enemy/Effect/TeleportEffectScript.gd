extends Particles2D

onready var main_tree : SceneTree = get_tree()
onready var effect_animation : AnimationPlayer = get_node("AnimationPlayer")

onready var spawn_enemy_timer : Timer = get_node("TimerNode/SpawnEnemyTimer")
onready var vanished_timer : Timer = get_node("TimerNode/VanishedTimer")

var is_spawn_enemy : bool = false
var number : int

var _vanished_wait_time : float = 1.0
var _spawn_enemy_wait_time : float = 2.0
var _enemy_prefab : PackedScene = preload("res://src/Enemy/Enemy.tscn")

func _ready() -> void:
	
	emitting = true
	
	if is_spawn_enemy:
		spawn_enemy_timer.start()
	else:
		vanished_timer.start()

func _do_spawn_enemy() -> void:
	
	var enemy : KinematicBody2D = _enemy_prefab.instance()
	
	get_parent().call_deferred("add_child", enemy)
	
	GlobalGameDataScript.enemy_count += 1
	enemy.number = number
	enemy.position = position

func _on_VanishedTimer_timeout() -> void:
	vanished_timer.stop()
	effect_animation.play("vanished")

func _on_SpawnEnemyTimer_timeout() -> void:
	
	spawn_enemy_timer.stop()
	_do_spawn_enemy()
	vanished_timer.start()
