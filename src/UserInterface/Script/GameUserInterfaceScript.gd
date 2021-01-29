extends Control

onready var ui_animation : AnimationPlayer = get_node("AnimationPlayer")
onready var ui_tween : Tween = get_node("Tween")

onready var question_label : Label = get_node("MarginContainer/VBoxContainer/QuestionLabel")

onready var xp_label : Label = get_node("XPLabel")
var previous_xp : int = 0
var current_xp : int = 0

onready var timer_label : Label = get_node("MarginContainer/VBoxContainer/TimerLabel")
onready var main_timer : Timer = get_node("TimerNode/Timer")

func _ready() -> void:
	
	GlobalGameDataScript.connect("random_question_is_picked", self, "_do_set_question_label")
	GlobalGameDataScript.connect("add_xp", self, "_configure_tween_xp")
	
	randomize()
	
	main_timer.wait_time = GlobalGameDataScript.game_time
	main_timer.start()

func _process(delta: float) -> void:
	
	var time_left : float = main_timer.time_left
	_do_set_timer_label_text(round(time_left))
	
	if time_left <= 30.0 and not ui_animation.is_playing():
		ui_animation.play("DangerTime")

func _do_set_timer_label_text(time_left : int) -> void:
	
	var minutes : String = str(floor(time_left/60))
	var seconds : String = str(time_left - (int(minutes) * 60))
	
	if len(minutes) == 1:
		minutes = "0" + minutes
	
	if len(seconds) == 1:
		seconds = "0" + seconds
	
	timer_label.text = minutes + ":" + seconds

func _do_set_question_label(number : int) -> void:
	question_label.text = "sqrt({main_question}) = . . .".format({"main_question" : number})

func _configure_tween_xp(new_amount : int) -> void:
	
	previous_xp = current_xp
	current_xp += new_amount
	
	ui_tween.interpolate_method(
		self, "_do_set_curreent_xp", previous_xp, current_xp, 0.5, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	ui_tween.start()

func _do_set_curreent_xp(amount_per_call : int) -> void:
	xp_label.text = "{amount} Pts".format({"amount" : amount_per_call})

func do_set_pause_timer(is_paused : bool) -> void:
	main_timer.paused = is_paused

func _on_Timer_timeout() -> void:
	main_timer.stop()
	GlobalGameDataScript.emit_signal("timeout")
