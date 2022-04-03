extends KinematicBody2D

const COIN = preload("res://scenes/ui/Coin.tscn")
const EXPLOSION = preload("res://scenes/Explosion.tscn")
const GRAVITY = 900.0
const FRICTION = 128.0
const MAX_VELOCITY = Vector2(32.0, 600.0)

var velocity = Vector2(0.0, 0.0)

var hit_timer = 0.0
var hit_time = 0.25
var blink_timer = 0.0
var blink_time = 0.01

var nav_timer = 1.0
var nav_time = 3.0
var nav_path = null
export var walk_speed = 21.0
export var coins = 10
var speed = 0.0
export var health = 6
var attacking = false

var game_over = false

func _update_nav():
	var target_node = get_parent().get_node("Target")
	nav_path = get_parent().get_node("Navigation2D").get_simple_path(position, target_node.position)
	
	if len(nav_path) < 2:
		speed = 0.0
		# TODO, need and end goal instead, and a lose condition, attack door, idk
	else:
		var target = nav_path[1]
		if position.x < target.x:
			speed = walk_speed
			$AnimatedSprite.flip_h = false
		else:
			speed = -walk_speed
			$AnimatedSprite.flip_h = true
	


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_nav()
	if GameState.difficulty == "normal":
		walk_speed *= 0.5
		health -= 1
	else:
		walk_speed *= 1.25


func _bound_vars():
	velocity.x = min(velocity.x, MAX_VELOCITY.x)
	velocity.x = max(velocity.x, -MAX_VELOCITY.x)
	velocity.y = min(velocity.y, MAX_VELOCITY.y)
	velocity.y = max(velocity.y, -MAX_VELOCITY.y)


func _process_environment(delta):
	velocity.y += GRAVITY * delta
	
	if velocity.x > 0:
		velocity.x = max(0, velocity.x - FRICTION * delta) 
	elif velocity.x < 0:
		velocity.x = min(0, velocity.x + FRICTION * delta)

	if is_on_floor():
		if velocity.y > 0:
			velocity.y = 0;
	if is_on_ceiling() and velocity.y < 0:
		velocity.y = 0


func _process_movement(_delta):
	var up = Vector2(0, -1)
	velocity = move_and_slide(velocity, up)


func kill():
	EnemyPopSound.pitch_scale = rand_range(0.9, 1.1)
	EnemyPopSound.play()
	
	for i in range(coins):
		var c = COIN.instance()
		c.position = position
		get_parent().add_child(c)
	
	for i in range(3):
		var e = EXPLOSION.instance()
		e.position = position + Vector2(rand_range(-6, 6), rand_range(-6, 6))
		get_parent().add_child(e)
		
	queue_free()


func hit(damage):
	health -= damage
	hit_timer = hit_time


func _set_animation():
	if hit_timer > 0:
		$AnimatedSprite.animation = "hit"
	else:
		$AnimatedSprite.animation = "run"


func attack():
	attacking = true
	$AnimatedSprite.animation = "attack"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.playing = true


func _process(delta):
	if game_over:
		visible = true
		$AnimatedSprite.animation = "run"
		$AnimatedSprite.frame = 0
		$AnimatedSprite.playing = false
		$Heart.visible = true
	else:
		if attacking:
			$AnimatedSprite.position.x = rand_range(-1.0, 1.0)
			$AnimatedSprite.position.y = rand_range(-1.0, 1.0)
		else:
			velocity.x = speed
			if hit_timer <= 0.0:
				_process_environment(delta)
				_bound_vars()
				_process_movement(delta)
			
			nav_timer -= delta
			if nav_timer <= 0.0:
				nav_timer += nav_time
				_update_nav()
				
			_set_animation()
			
		if hit_timer > 0:
			hit_timer -= delta
			if blink_timer > 0:
				blink_timer -= delta
			else:
				blink_timer += blink_time
				visible = !visible
		else:
			visible = true
				
		if health <= 0:
			kill()


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "attack":
		get_parent().lose()
