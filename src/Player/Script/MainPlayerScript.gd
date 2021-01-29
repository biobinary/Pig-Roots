extends KinematicBody2D

onready var player_sprite : Sprite = get_node("Sprite")
onready var player_collision : CollisionShape2D = get_node("CollisionShape2D")
onready var node_positioning : Node2D = get_node("NodePlayerDirectionPositioning")

# Sound Effect Property
onready var jump_sound_effect : AudioStreamPlayer = get_node("SoundEffect/JumpSound")
onready var hammer_hit_effect : AudioStreamPlayer = get_node("SoundEffect/HammerHitEffect")
# ------------------------------------------------------------------------------------------

# Character Animation Property
onready var animation_tree : AnimationTree = get_node("AnimationTree")
onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
# -------------------------------------------------------------------------------------------------------

export(float) var player_speed : float = 60.0
export(float) var gravity : float = 20.0
export(float) var jump_force : float = 100.0
export(float) var player_acceleration : float = 5.0
export(float) var player_friction : float = 60.0
export(float) var air_friction : float = 60.0

# Attack Cooldown Property
onready var attack_cooldown_timer : Timer = get_node("TimerNode/AttackCooldown")
var _is_can_attack : bool = true
# --------------------------------------------------------------------------------

# Attack Cooldown User Interface
onready var attack_stamina_control : Control = get_node("NodePlayerDirectionPositioning/AttackStamina")
onready var attack_cooldown_texture_progress : TextureProgress = get_node("NodePlayerDirectionPositioning/AttackStamina/TextureProgress")
onready var texture_progrees_tween : Tween = get_node("NodePlayerDirectionPositioning/AttackStamina/Tween")
# ---------------------------------------------------------------------------------------------------------

var _player_velocity : Vector2 = Vector2.ZERO
var _is_attacking : bool = false
var _player_horizontal_direction : int = 1
var _jump_count : int = 0

onready var dust_spawner_location : Position2D = get_node("NodePlayerDirectionPositioning/DustParticleSpawner")
var _dust_effect_prefab : PackedScene = preload("res://src/Player/JumpEffect.tscn")

func _ready() -> void:
	attack_stamina_control.hide()

func _physics_process(delta: float) -> void:
	
	# Get Current Playing Animation
	var current_animation_node : String = state_machine.get_current_node()
	# --------------------------------------------------------------------
	
	if current_animation_node == "Idle" and _is_attacking:
		_is_attacking = false
	
	# Accept User Input To Move The Character If Character No Longer Attack
	if not _is_attacking:
		_do_get_input_movement(delta)
	# --------------------------------------------------------------------
	
	node_positioning.position.x = player_collision.position.x
	_player_velocity = move_and_slide(_player_velocity, Vector2.UP)

	if Input.is_action_just_pressed("Attack") and not _is_attacking and _is_can_attack:
	
		hammer_hit_effect.play()
	
		if _player_horizontal_direction == 1:
			state_machine.travel("Attack")
		else:
			state_machine.travel("AttackLeftDirection")
	
		_player_velocity = Vector2.ZERO
		_is_attacking = true

		_is_can_attack = false
		_do_recharge_texture_progrees()
		attack_cooldown_timer.start()

func _do_get_input_movement(delta : float) -> void:
	
	# Apply Gravity To The Character
	_player_velocity.y += gravity
	_player_velocity.y = min(_player_velocity.y, 450.0)
	# ---------------------------------------------------
	
	var is_player_on_floor : bool = false
	
	var new_direction : float = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	var is_fraction : bool = false

	if new_direction < 0.0:
		
		state_machine.travel("Run")
		
		_player_velocity.x = max(_player_velocity.x - player_acceleration, -player_speed)
		_player_horizontal_direction = -1
		
		player_sprite.flip_h = true
		player_collision.position.x = abs(player_collision.position.x) * -1

	elif new_direction > 0.0:
		
		state_machine.travel("Run")
		
		_player_velocity.x = min(_player_velocity.x + player_acceleration, player_speed)
		_player_horizontal_direction = 1
		
		player_sprite.flip_h = false
		player_collision.position.x = abs(player_collision.position.x)
	
	else:
		is_fraction = true


	if is_on_floor():
		
		if _jump_count != 0:
			_jump_count = 0
		
		if is_fraction:
			state_machine.travel("Idle")
			_player_velocity.x = move_toward(_player_velocity.x, 0.0, player_friction)
		
		is_player_on_floor = true
		
	else:
		
		state_machine.travel("Jump")
		if is_fraction:
			_player_velocity.x = move_toward(_player_velocity.x, 0.0, air_friction)

	if Input.is_action_just_pressed("Jump") and _jump_count < 2:
		_player_velocity.y = -jump_force
		
		jump_sound_effect.play()
		
		if is_player_on_floor:
			_do_spawn_dust()
		
		_jump_count += 1

func _on_AttackCooldown_timeout() -> void:
	attack_cooldown_timer.stop()
	_is_can_attack = true

func _do_recharge_texture_progrees() -> void:
	
	attack_stamina_control.show()
	
	texture_progrees_tween.interpolate_property(
		attack_cooldown_texture_progress, "value", 0, attack_cooldown_texture_progress.max_value,
		attack_cooldown_timer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN
	)
	
	texture_progrees_tween.start()
	
	yield(texture_progrees_tween, "tween_completed")
	
	attack_stamina_control.hide()
	attack_cooldown_texture_progress.value = 0
	
func do_freeze_body(is_freeze : bool) -> void:
	
	player_collision.disabled = is_freeze
	set_physics_process(not is_freeze)
	
	if is_freeze:
		state_machine.travel("Idle")
		_player_velocity = Vector2.ZERO

func _do_spawn_dust() -> void:
	
	var dust : AnimatedSprite = _dust_effect_prefab.instance()
	
	get_tree().root.add_child(dust)
	
	dust.global_position = dust_spawner_location.global_position
	dust.play("Idle")



