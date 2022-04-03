extends Node2D


const DIALOGUE = preload("res://scenes/ui/Dialogue.tscn")
var first_done = false
var second_done = false
var third_done = false
var end_timer = 0.0
var end_timer_2 = 0.0
var dummy_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()
	var d = DIALOGUE.instance()
	d.init("tutorial1")
	add_child(d)
	if not Level1Music.playing:
		Level1Music.play()
	$Player.attack_damage = 0
	$Player.coins = 100
	if not Level1Music.playing:
		Level1Music.play()


func update_text():
	$CoinsText.set_text(str($Player.coins))
	$BombText.set_text("(C/E) " + str($Player.bombs))
	$AttackText.set_text(str($Player.attack_damage))
	$AttackSpeedText.set_text(str(1.0 / $Player.attack_speed).substr(0, 3))
	$SpeedText.set_text(str($Player.MAX_VELOCITY.x))


func end():
	var d = DIALOGUE.instance()
	d.init("tutorial5")
	add_child(d)
	end_timer_2 = 0.5



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# doing this per frame is dumb but whatever, im lazy and time constrained
	update_text()
	if $Player.attack_damage > 0 and not third_done:
		var d = DIALOGUE.instance()
		d.init("tutorial4")
		add_child(d)
		third_done = true
	
	if end_timer > 0.0:
		end_timer -= delta
		if end_timer <= 0.0:
			end()
	if end_timer_2 > 0.0:
		end_timer_2 -= delta
		if end_timer_2 <= 0.0:
			get_tree().change_scene_to(load("res://scenes/ui/StartMenu.tscn"))


func _on_WalkArea_body_entered(body):
	if not first_done and body.name == "Player":
		var d = DIALOGUE.instance()
		d.init("tutorial2")
		add_child(d)
		first_done = true


func _on_ShopArea_body_entered(body):
	if not second_done and body.name == "Player":
		var d = DIALOGUE.instance()
		d.init("tutorial3")
		add_child(d)
		second_done = true


func _on_DummyArea_body_entered(body):
	if body.name == "Player" and not dummy_dead:
		body.hittable_monsters.append($Dummy)


func _on_DummyArea_body_exited(body):
	if body.name == "Player" and not dummy_dead:
		body.hittable_monsters.erase($Dummy)
