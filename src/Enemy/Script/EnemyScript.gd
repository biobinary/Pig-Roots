extends KinematicBody2D

onready var enemy_animation : AnimationPlayer = get_node("AnimationPlayer")
onready var enemy_tween : Tween = get_node("Tween")

onready var enemy_sprite : Sprite = get_node("Sprite")
onready var enemy_collision_shape : CollisionShape2D = get_node("CollisionShape2D")

onready var label_holder : Position2D = get_node("CollisionShape2D/Position2D")
onready var answer_label : Label = get_node("CollisionShape2D/Position2D/CenterContainer/AnswerLabel")

onready var blood_effect : Particles2D = get_node("BloodEffect")

# Idle Timer
onready var idle_timer : Timer = get_node("TimerNode/IdleTimer")
var idle_timer_wait_time : Vector2 = Vector2(0.5, 0.75)
# ----------------------------------------------------------------

# Walking Timer
onready var walking_timer : Timer = get_node("TimerNode/WalkingTimer")
var walking_timer_wait_time : Vector2 = Vector2(1.0, 1.5)
# --------------------------------------------------------------------

# Movement Property
export(float) var enemy_move_speed : float = 60.0
export(float) var gravity : float = 9.8
var direction : Vector2 = Vector2(-1.0, 0.0)
# ------------------------------------------------

# Enemy State
enum enemy_state { IDLE, WALKING, KNOCKBACK }
var current_enemy_state : int
# ---------------------------------

# Enemy Direction
enum DIRECTION { RIGHT = 1, LEFT = -1 }
var current_direction : int = DIRECTION.LEFT setget _set_new_direction_facing
# ----------------------------------------------------------------------------

# Answer Number
var number : int
# --------------

# Knockback Property
var _knockback_power : float = 40.0
var _knockback_timeout : float = 0.5
var is_been_hit : bool = false
# -----------------------------------

# Private Property
var _enemy_velocity : Vector2 = Vector2()
# ----------------------------------------

func _ready() -> void:
	
	randomize()
	scale = Vector2.ZERO
	
	answer_label.text = str(number)
	
	var direction : PoolIntArray = PoolIntArray([1, -1])
	self.current_direction = direction[randi() % 2]
	
	current_enemy_state = randi() % 2
	
	idle_timer.wait_time = rand_range(idle_timer_wait_time.x, idle_timer_wait_time.y)
	walking_timer.wait_time = rand_range(walking_timer_wait_time.x, walking_timer_wait_time.y)

	set_physics_process(false)
	enemy_animation.play("Spawn")

func _physics_process(delta: float) -> void:
	
	_enemy_velocity.y += gravity
	_enemy_velocity.y = min(_enemy_velocity.y, 450.0)
	
	if current_enemy_state == enemy_state.IDLE:
		
		if idle_timer.is_stopped():
			idle_timer.start()
			
		enemy_animation.play("Idle")
		_enemy_velocity.x = 0.0
		
	else:
		
		if walking_timer.is_stopped():
			walking_timer.start()
		
		_do_get_movement()
	
	_enemy_velocity = move_and_slide(_enemy_velocity, Vector2.UP)

func _do_get_movement() -> void:
	
	enemy_animation.play("Run")
	_enemy_velocity.x = direction.x * enemy_move_speed

func _set_new_direction_facing(new_direction : int) -> void:
	
	if new_direction == DIRECTION.RIGHT:
		direction.x = DIRECTION.RIGHT
		enemy_sprite.flip_h = true
		enemy_collision_shape.position.x = abs(enemy_collision_shape.position.x) * -1
	else:
		direction.x = DIRECTION.LEFT
		enemy_sprite.flip_h = false
		enemy_collision_shape.position.x = abs(enemy_collision_shape.position.x)

func _on_IdleTimer_timeout() -> void:
	
	idle_timer.stop()
	idle_timer.wait_time = rand_range(idle_timer_wait_time.x, idle_timer_wait_time.y)
	
	current_enemy_state = randi() % 2

func _on_WalkingTimer_timeout() -> void:
	
	walking_timer.stop()
	walking_timer.wait_time = rand_range(walking_timer_wait_time.x, walking_timer_wait_time.y)
	
	current_enemy_state = randi() % 2

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	
	if anim_name == "Spawn":
		set_physics_process(true)

func do_enemy_death(attack_direction : int) -> void:
	
	is_been_hit = true
	get_node("SoundEffectNode/PigSound").play()
	
	set_physics_process(false)
	idle_timer.stop()
	walking_timer.stop()
	
	if attack_direction == DIRECTION.LEFT:
		
		enemy_sprite.flip_h = true
		blood_effect.process_material.direction = Vector3(1, 0, 0)
		blood_effect.emitting = true
		enemy_animation.play("DieLeftDirection")
		
	else:
		
		enemy_sprite.flip_h = false
		blood_effect.process_material.direction = Vector3(-1, 0, 0)
		blood_effect.emitting = true
		enemy_animation.play("Die")

	var new_position : Vector2 = position
	new_position += Vector2(attack_direction, 0) * _knockback_power

	var new_color : Color = modulate
	new_color.a = 0.0

	# Apply Knockback Effect
	enemy_tween.interpolate_method(
		self, "_do_knockback", Vector2(attack_direction, 0) * _knockback_power, 
		Vector2(attack_direction, 0) * 0.0, _knockback_timeout, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	# ----------------------------------------------------------------------------------------------
	
	# Make Enemy Not Visible
	enemy_tween.interpolate_property( self, "modulate", modulate, new_color, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.5 )
	# ----------------------------------------------------------------------------------------------------------------------
	
	# Delete Enemy Node
	enemy_tween.interpolate_callback( self, 1.0, "delete_node" )
	# ----------------------------------------------------------

	enemy_tween.start()

func _do_knockback(velocity : Vector2) -> void:
	move_and_slide(velocity)

func delete_node() -> void:
	GlobalGameDataScript.enemy_count -= 1
	queue_free()
