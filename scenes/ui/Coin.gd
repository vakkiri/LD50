extends Node2D

var wander_timer = rand_range(0.5, 0.75)
var velocity = Vector2(0, 0)

const MAX_SPEED = 96.0
const ACCEL = 200.0

var in_player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.x = rand_range(0, 32.0)
	velocity.y = rand_range(0, 32.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wander_timer > 0.0:
		wander_timer -= delta
	else:
		var dx = get_parent().get_node("Player").position.x - position.x
		var dy = get_parent().get_node("Player").position.y - position.y
		
		if dx > 4.0:
			if velocity.x < MAX_SPEED:
				velocity.x += ACCEL * delta
		elif dx < -4.0:
			if velocity.x > -MAX_SPEED:
				velocity.x -= ACCEL * delta
		else:
			velocity.x = 0.0
			
		if dy > 4.0:
			if velocity.y < MAX_SPEED:
				velocity.y += ACCEL * delta
		elif dy < 4.0:
			if velocity.y > -MAX_SPEED:
				velocity.y -= ACCEL * delta
		else:
			velocity.y = 0.0
	
	position += velocity * delta
	
	if wander_timer <= 0.0 and in_player:
		get_parent().get_node("Player").coins += 1
		CoinSound.pitch_scale = rand_range(0.98, 1.02)
		CoinSound.play()
		queue_free()


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		in_player = true


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		in_player = false
