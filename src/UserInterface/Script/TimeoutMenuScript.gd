extends Control

onready var ui_animation : AnimationPlayer = get_node("TransitionsAnimation")
onready var button_sound_effect : AudioStreamPlayer = get_node("ButtonClickEffect")

onready var points_label : Label = get_node("Stats/Points")
onready var correct_percentage : Label = get_node("Stats/CorrectPercentage")
onready var summary : Label = get_node("Stats/Summary")

var percentage : int
var grade : String

var grade_dict : Dictionary = {
	"A+" : 90,
	"A" : 80,
	"A-" : 70,
	"B+" : 60,
	"B" : 50,
	"B-" : 40,
	"C" : 30
}

var _is_clicked : bool = true

func _ready() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	percentage = _calculate_percaentage()
	grade = _calculate_grade()
	
	_set_stats()

	yield(ui_animation, "animation_finished")
	_is_clicked = false

func _set_stats() -> void:
	points_label.text = "points = " + str(GlobalGameDataScript.player_xp)
	correct_percentage.text = "percentage of correct answers = " + str(percentage) + "%"
	summary.text = "grade = " + grade

func _calculate_grade() -> String:
	
	for letter in grade_dict:
		if percentage >= grade_dict[letter]:
			return letter
			
	return "F"

func _calculate_percaentage() -> int:
	
	var correct_answer : int = GlobalGameDataScript.correct_answer
	var questions_amount : int = GlobalGameDataScript.questions_amount
	
	return int((float(correct_answer) / float(questions_amount)) * 100)

func _on_ReturnToHomeButton_pressed() -> void:
	
	if not _is_clicked:
		
		_is_clicked = true
		
		button_sound_effect.play()
		
		ui_animation.play_backwards("OpenUpCover")
		yield(ui_animation, "animation_finished")
		
		GlobalGameDataScript.do_reset_data()
		get_tree().change_scene("res://src/UserInterface/MainMenu.tscn")
