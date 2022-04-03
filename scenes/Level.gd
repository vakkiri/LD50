extends Node2D


var time_asleep = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Level1Music.playing:
		Level1Music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# doing this per frame is dumb but whatever, im lazy and time constrained
	time_asleep += delta
	$TimeAsleepText.set_text("Time Asleep: " + str(int(time_asleep)))
	$CoinsText.set_text(str($Player.coins))
	$BombText.set_text(str($Player.bombs))
	$AttackText.set_text(str($Player.attack_damage))
	$AttackSpeedText.set_text(str(1.0 / $Player.attack_speed).substr(0, 3))
	$SpeedText.set_text(str($Player.MAX_VELOCITY.x))
