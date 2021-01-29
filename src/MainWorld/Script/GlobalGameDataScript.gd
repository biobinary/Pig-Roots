extends Node

signal random_question_is_picked(number)
signal shake_camera(amplitude, timeout, is_change_background_color)
signal add_xp(amount)
signal switch_world()
signal timeout()

var question_range : Array = []
var game_time : int = 0 

enum DIFFICULTY { EASY = 150, MEDIUM = 120, HARD = 60 }
var game_difficulty : int setget _set_game_difficulty

func _set_game_difficulty(new_difficulty) -> void:
	game_difficulty = new_difficulty
	
	match game_difficulty:
		DIFFICULTY.EASY:
			question_range = [1, 10]
			game_time = 150
		DIFFICULTY.MEDIUM:
			question_range = [10, 30]
			game_time = 120
		DIFFICULTY.HARD:
			question_range = [25, 50]
			game_time = 60

# Enemy Count
var enemy_count : int = 0 setget _set_enemy_count
func _set_enemy_count(new_value : int) -> void:
	enemy_count = new_value
	
	if enemy_count == 0:
		emit_signal("switch_world")
# -------------------------------------------------

# Player XP
var player_xp : int
# ------------------

# Question
var questions_lst : Dictionary
var current_question : int

var questions_amount : int = 0
var correct_answer : int = 0
# ----------------------------

func _ready() -> void:
	randomize()

func do_add_new_question() -> void:
	
	var base_number : int = round(rand_range(question_range[0], question_range[1]))
	var question : int = pow(base_number, 2)
	var answer : int = sqrt(question)

	while questions_lst.has(question):
		base_number = round(rand_range(question_range[0], question_range[1]))
		question = pow(base_number, 2)
		answer = sqrt(question)

	questions_amount += 1
	questions_lst[question] = answer

func do_pick_random_question() -> void:
	var questions_keys : PoolIntArray = PoolIntArray(questions_lst.keys())
	
	if questions_keys.size() == 0:
		return
	
	var rand_index : int = randi() % questions_keys.size()
	
	current_question = questions_keys[rand_index]
	emit_signal("random_question_is_picked", current_question)

func do_check_question(answer : int) -> void:
	
	var current_answer : int = pow(answer, 2)
	var is_correct : bool = current_question == current_answer
	
	questions_lst.erase(current_answer)
	
	if is_correct:
		
		player_xp += answer
		correct_answer += 1
		
		emit_signal("add_xp", answer)
		emit_signal("shake_camera", 2, 0.45, false)
		
		do_pick_random_question()
	else:
		emit_signal("shake_camera", 10, 0.45)

func do_reset_data() -> void:
	
	questions_lst.clear()
	current_question = 0

	question_range.clear()
	game_time = 0.0

	player_xp = 0
	enemy_count = 0

	questions_amount = 0
	correct_answer = 0
