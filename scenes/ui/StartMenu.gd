extends Node2D

var selected = "normal"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("player_down") or Input.is_action_just_pressed("player_up"):
		if selected == "hard":
			selected = "normal"
			$Selector.rect_position = Vector2(139, 113)
		else:
			selected = "hard"
			$Selector.rect_position = Vector2(139, 129)
	elif Input.is_action_just_pressed("dialogue_next"):
		GameState.difficulty = selected
		get_tree().change_scene_to(load("res://scenes/Level.tscn"))
		
