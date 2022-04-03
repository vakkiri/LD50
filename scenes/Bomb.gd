extends KinematicBody2D

const EXPLOSION = preload("res://scenes/BombExplosion.tscn")
const GRAVITY = 1200.0

var explosion_timer = 4.0
var velocity = Vector2(0, 0)
var on_ground = false
var bounces = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	explosion_timer -= delta
	
	velocity.y += GRAVITY * delta
	
	var friction = 50.0
		
	if velocity.x > 0.0:
		velocity.x = max(0.0, velocity.x - friction * delta)
	elif velocity.x < 0.0:
		velocity.x = min(0.0, velocity.x + friction * delta)
	
	var movement = move_and_slide(velocity, Vector2(0, -1))
	
	if movement.y < velocity.y:
		velocity.y = -150.0 / (2.0 * (bounces+1))
		velocity.x *= 0.8
		bounces += 1
	
	if explosion_timer <= 1.0 and not $AnimatedSprite.playing:
		$AnimatedSprite.playing = true
		
	if explosion_timer <= 0.0:
		BombSound.play()
		var e = EXPLOSION.instance()
		e.position = position
		get_parent().add_child(e)
		queue_free()
