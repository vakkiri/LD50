extends KinematicBody2D


const BOMB = preload("res://scenes/Bomb.tscn")

var velocity = Vector2(0,0)
var run_accel = 450.0
var base_dash = Vector2(100.0, 185.0)
var MAX_VELOCITY = Vector2(110.0, 1024.0)

const LEFT = 0
const RIGHT = 1

var GRAVITY = 1400.0
const AIR_RESIST = 100.0
const FRICTION = 128.0
const JUMP_PERIOD = 0.1
const MAX_FALL = 8

var bombs = 0

var last_direction = RIGHT

var movement_held = false
var hit_timer = 0.0
var charge_timer = 0.0
var post_dash_timer = 0.0
var post_dash_time = 0.15
var max_dash_scale = 1.5

var dash_attack_timer = 0.0
var dash_attack_time = (post_dash_time / 2.0)

var attack_speed = 0.55
var attack_timer = 0.0
var dash_time = 0.5
var dash_timer = 0.0
var attack_damage = 2

var hittable_monsters = []

var coins = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.difficulty == "normal":
		post_dash_timer += 0.05
		GRAVITY -= 200


func attack_playing():
	return $AnimatedSprite.animation in ["attack", "dash_attack"]


func _bound_vars():
	if post_dash_timer <= 0.0:
		velocity.x = min(velocity.x, MAX_VELOCITY.x)
		velocity.x = max(velocity.x, -MAX_VELOCITY.x)
		velocity.y = min(velocity.y, MAX_VELOCITY.y)
		velocity.y = max(velocity.y, -MAX_VELOCITY.y)


func _set_animation():
	$AnimatedSprite.flip_h = last_direction == LEFT
	
	# don't cancel attack animations
	if attack_playing():
		pass
	else:
		$AnimatedSprite.playing = true
		if Input.is_action_pressed("player_dash") and dash_timer <= 0.0:
			$AnimatedSprite.animation = "pre_dash"
		elif movement_held:
			$AnimatedSprite.animation = "run"
		else:
			$AnimatedSprite.animation = "idle"
		
	visible = hit_timer <= 0 or rand_range(0, 1) < 0.35

	# if we are fully charged
	if _dash_scale() >= max_dash_scale:	
		$SwordChargeParticles.emitting = true
		$SwordChargeParticles2.emitting = true
		$AnimatedSprite.position.x = rand_range(-0.5, 0.5)
		$AnimatedSprite.position.y = rand_range(-0.5, 0.5)
	else:
		$AnimatedSprite.position = Vector2(0.0, 0.0)
		$SwordChargeParticles.emitting = false
		$SwordChargeParticles2.emitting = false
	
	if last_direction == RIGHT:
		$SwordChargeParticles.position = Vector2(-8.0, 3.0)
		$SwordChargeParticles2.position = Vector2(-6.0, 3.0)
	else:
		$SwordChargeParticles.position = Vector2(8.0, 3.0)
		$SwordChargeParticles2.position = Vector2(6.0, 3.0)


func _update_timers(delta):
	if hit_timer > 0:
		hit_timer -= delta
	if post_dash_timer > 0:
		post_dash_timer -= delta
		dash_attack_timer -= delta
		# periodically deal damage during dash
		if dash_attack_timer <= 0.0:
			dash_attack_timer += dash_attack_time
			_dash_attack()
	if dash_timer > 0.0:
		dash_timer -= delta
	if attack_timer > 0.0:
		attack_timer -= delta


func _attack():
	SwordSound.play()
	if $AnimatedSprite.animation == "attack":
		if $AnimatedSprite.frame == 0:
			$AnimatedSprite.frame = 1
		else:
			$AnimatedSprite.frame = 0
	else:
		$AnimatedSprite.animation = "attack"
		$AnimatedSprite.frame = 0
	$AnimatedSprite.playing = true
	var dead_monsters = []
	for monster in hittable_monsters:
		monster.hit(attack_damage)
		if monster.health < 0:
			dead_monsters.append(monster)
	for monster in dead_monsters:
		hittable_monsters.erase(monster)


func _dash_scale():
	return 0.5 + (charge_timer * 3.0)


func _dash_attack():
	var dead_monsters = []
	for monster in hittable_monsters:
		monster.hit(attack_damage / 2.0)
		if monster.health < 0:
			dead_monsters.append(monster)
	for monster in dead_monsters:
		hittable_monsters.erase(monster)


func _dash():
	var dash
	
	if Input.is_action_pressed("player_up"):
		if movement_held:
			dash = Vector2(base_dash.x / 2.0, -base_dash.y)
		else:
			dash = Vector2(0.0, -base_dash.y)
	else:
		if velocity.y > 0.0:
			velocity.y = 0.0
		dash = Vector2(base_dash.x, -16.0)
		
	if last_direction == LEFT:
		dash.x *= -1.0
		
	var dash_scale = min(_dash_scale(), max_dash_scale)
	velocity += dash * dash_scale
	post_dash_timer = post_dash_time
	
	$AnimatedSprite.animation = "dash_attack"
	$AnimatedSprite.frame = 0
	$AnimatedSprite.playing = true
	DashSound.play()


func _throw_bomb():
	if bombs > 0:
		var b = BOMB.instance()
		b.position = position
		# TODO charge shot? idk
		if last_direction == LEFT:
			b.velocity.x = -180.0
		else:
			b.velocity.x = 180.0
		b.velocity.y = -100.0
		get_parent().add_child(b)
		bombs -= 1


func _handle_input(delta):
	if dash_timer <= 0.0:
		if Input.is_action_pressed("player_dash"):
			charge_timer += delta
		else:
			if Input.is_action_just_released("player_dash"):
				_dash()
				dash_timer = dash_time
			charge_timer = 0.0
		
	if Input.is_action_just_pressed("player_left"):
		if last_direction == RIGHT:
			"""
			var e = RUN_EFFECT.instance()
			e.position = position + Vector2(8, 0)
			e.flip()
			get_parent().add_child(e)
			"""
			if velocity.x > 0:
				velocity.x = 0
		last_direction = LEFT
	if Input.is_action_just_pressed("player_right"):
		if last_direction == LEFT:
			"""
			var e = RUN_EFFECT.instance()
			e.position = position + Vector2(-8, 0)
			get_parent().add_child(e)
			"""
			if velocity.x < 0:
				velocity.x = 0
		last_direction = RIGHT
	if Input.is_action_just_released("player_left") and Input.is_action_pressed("player_right"):
		last_direction = RIGHT
	if Input.is_action_just_released("player_right") and Input.is_action_pressed("player_left"):
		last_direction = LEFT
		
	if last_direction == LEFT and Input.is_action_pressed("player_left"):
		velocity.x -= run_accel * delta
	elif last_direction == RIGHT and Input.is_action_pressed("player_right"):
		velocity.x += run_accel * delta
	
	if Input.is_action_pressed("player_attack") and attack_timer <= 0.0:
		_attack()
		attack_timer += attack_speed
	
	if Input.is_action_just_pressed("player_bomb"):
		_throw_bomb()
	
	movement_held = Input.is_action_pressed("player_left") or Input.is_action_pressed("player_right")


func _process_environment(delta):
	var air_factor = 1.0
	var friction_factor = 1.0
	var gravity_factor = 1.0
		
	if post_dash_timer > 0.0:
		gravity_factor = 0.0
		
	if not movement_held:
		friction_factor = 8.0
		
	velocity.y += GRAVITY * delta * gravity_factor
	
	
	if velocity.x > 0:
		if is_on_floor():
			velocity.x = max(0, velocity.x - FRICTION * delta * friction_factor) 
		else:
			velocity.x = max(0, velocity.x - AIR_RESIST * delta * air_factor * friction_factor)
	elif velocity.x < 0:
		if is_on_floor():
			velocity.x = min(0, velocity.x + FRICTION * delta * friction_factor)
		else:
			velocity.x = min(0, velocity.x + AIR_RESIST * delta * air_factor * friction_factor)
		
	if is_on_floor():
		"""
		if fall_timer > 0.1:
			$LandSound.play()
		"""
		if velocity.y > 0:
			velocity.y = 0;
	if is_on_ceiling() and velocity.y < 0:
		velocity.y = 0


func _process_movement(_delta):
	var up = Vector2(0, -1)
	velocity = move_and_slide(velocity, up)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_timers(delta)
	_handle_input(delta)
	_set_animation()
	_process_environment(delta)
	_bound_vars()
	_process_movement(delta)


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation in ["dash_attack", "attack"]:
		$AnimatedSprite.animation = "idle"


func _on_SwordArea_body_entered(body):
	if body.is_in_group("monster") and body.health > 0:
		hittable_monsters.append(body)


func _on_SwordArea_body_exited(body):
	if body.is_in_group("monster"):
		hittable_monsters.erase(body)
