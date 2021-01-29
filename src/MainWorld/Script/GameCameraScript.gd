extends Camera2D

export(NodePath) var background_node_path : NodePath
onready var background_node : Sprite = get_node(background_node_path)

onready var camera_tween : Tween = get_node("Tween")
onready var origin_offset : Vector2 = offset

func _ready() -> void:
	randomize()
	GlobalGameDataScript.connect("shake_camera", self, "_do_init_shake_camera")
	
func _do_init_shake_camera(amplitude : float, timeout : float, is_change_background_color : bool = true) -> void:
	
	if is_change_background_color:
		background_node.modulate = Color("ff0000")
	
	camera_tween.interpolate_method(
		self, "_do_shake_camera", amplitude, 0.0, timeout, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	camera_tween.start()
	
	yield(camera_tween, "tween_completed")
	background_node.modulate = Color("000000")

func _do_shake_camera(shake_power : float) -> void:
	
	offset = Vector2(
		origin_offset.x + rand_range(-shake_power, shake_power),
		origin_offset.y + rand_range(-shake_power, shake_power)
	)
