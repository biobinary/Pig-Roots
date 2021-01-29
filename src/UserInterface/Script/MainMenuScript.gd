extends Control

onready var main_menu_animation_player : AnimationPlayer = get_node("TransitionsAnimation")
onready var button_sound_effect : AudioStreamPlayer = get_node("ButtonClickSound")

var _is_clicked : bool = true

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	yield(main_menu_animation_player, "animation_finished")
	_is_clicked = false

func _on_QuitButton_pressed() -> void:
	if not _is_clicked:
		
		button_sound_effect.play()
		yield(button_sound_effect, "finished")
		
		get_tree().quit()

func _on_PlayButton_pressed() -> void:
	
	if not _is_clicked:
		
		_is_clicked = true
	
		button_sound_effect.play()
	
		main_menu_animation_player.play_backwards("OpenUpCover")
		yield(main_menu_animation_player, "animation_finished")

		get_tree().change_scene("res://src/UserInterface/LevelPicker.tscn")
