extends Control

onready var animation_player : AnimationPlayer = get_node("TransitionsAnimation")
onready var button_sound_effect : AudioStreamPlayer = get_node("ButtonClickSound")

signal cover_is_closed()
var _is_clicked : bool = true

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	yield(animation_player, "animation_finished")
	_is_clicked = false

func _on_BackButton_pressed() -> void:
	
	if not _is_clicked:
		
		_close_the_cover()
		yield(self, "cover_is_closed")
		
		get_tree().change_scene("res://src/UserInterface/MainMenu.tscn")

func _on_Easy_pressed() -> void:
	
	if not _is_clicked:
		
		GlobalGameDataScript.game_difficulty = GlobalGameDataScript.DIFFICULTY.EASY
		
		_close_the_cover()
		yield(self, "cover_is_closed")
		_play_the_game()

func _on_Medium_pressed() -> void:
	
	if not _is_clicked:
		
		GlobalGameDataScript.game_difficulty = GlobalGameDataScript.DIFFICULTY.MEDIUM
		
		_close_the_cover()
		yield(self, "cover_is_closed")
		_play_the_game()

func _on_Hard_pressed() -> void:
	
	if not _is_clicked:

		GlobalGameDataScript.game_difficulty = GlobalGameDataScript.DIFFICULTY.HARD
		
		_close_the_cover()
		yield(self, "cover_is_closed")
		_play_the_game()

func _close_the_cover() -> void:
	
	_is_clicked = true
	
	button_sound_effect.play()
	
	animation_player.play_backwards("OpenUpCover")
	yield(animation_player, "animation_finished")
	
	emit_signal("cover_is_closed")

func _play_the_game() -> void:
	get_tree().paused = true
	get_tree().change_scene("res://src/MainWorld/WorldOne.tscn")
