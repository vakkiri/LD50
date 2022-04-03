extends Node2D


const DIALOGUE = preload("res://scenes/ui/Dialogue.tscn")
var time_asleep = 0.0
var lose_timer = 2.0
var max_time = 300.0
var finished = false
var won = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.difficulty == "normal":
		max_time = 60.0 * 3
	else:
		max_time = 60.0 * 5
	update_text()
	var d = DIALOGUE.instance()
	d.init("intro")
	add_child(d)
	if not Level1Music.playing:
		Level1Music.play()


func update_text():
	$TimeAsleepText.set_text("Time Asleep: " + str(int(time_asleep)))
	$CoinsText.set_text(str($Player.coins))
	$BombText.set_text("(C/E) " + str($Player.bombs))
	$AttackText.set_text(str($Player.attack_damage))
	$AttackSpeedText.set_text(str(1.0 / $Player.attack_speed).substr(0, 3))
	$SpeedText.set_text(str($Player.MAX_VELOCITY.x))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# doing this per frame is dumb but whatever, im lazy and time constrained
	if not finished:
		if not $BedroomDoor.visible:
			time_asleep += delta
			update_text()
			if time_asleep >= max_time:
				$Snot.visible = false
				stop_game()
				var d = DIALOGUE.instance()
				d.init("win")
				add_child(d)
				won = true
				finished = true
		else:
			lose_timer -= delta
			$Snot.visible = false
			if lose_timer <= 0.0:
				var d = DIALOGUE.instance()
				d.init("lose")
				add_child(d)
				finished = true
	else:
		if not won:
			$TryAgain.visible = true
		else:
			$WinScreen.visible = true
			if Input.is_action_just_pressed("dialogue_next"):
				get_tree().change_scene_to(load("res://scenes/ui/StartMenu.tscn"))


func stop_game():
	for c in get_children():
		if c.is_in_group("monster"):
			c.game_over = true
		elif c.is_in_group("spawner"):
			c.active = false


func lose():
	if not $BedroomDoor.visible:
		stop_game()
		$BedroomDoor.show()
		


func _on_DoorTrigger_body_entered(body):
	# TODO this is actually not what should happen, we should set the monster to an attack anim
	# and actually trigger door when that anim finishes
	if body.is_in_group("monster") and not $BedroomDoor.visible:
		body.attack()
