extends AnimatedSprite

var selected = "yes"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		if Input.is_action_just_pressed("player_left"):
			selected = "yes"
			frame = 0
		elif Input.is_action_just_pressed("player_right"):
			selected = "no"
			frame = 1
		
		if Input.is_action_just_pressed("dialogue_next"):
			# TODO one of these will be wrong
			if selected == "yes":
				get_tree().reload_current_scene()
			else:
				get_tree().change_scene_to(load("res://scenes/ui/StartMenu.tscn"))
