extends StaticBody2D


const COIN = preload("res://scenes/ui/Coin.tscn")
const EXPLOSION = preload("res://scenes/Explosion.tscn")


var health = 5
var hit_timer = 0.0
var hit_time = 0.25
var blink_timer = 0.0
var blink_time = 0.01
var coins = 10

func hit(damage):
	health -= damage
	hit_timer = hit_time


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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


func kill():
	for i in range(coins):
		var c = COIN.instance()
		c.position = position
		get_parent().add_child(c)
	
	for i in range(3):
		var e = EXPLOSION.instance()
		e.position = position + Vector2(rand_range(-6, 6), rand_range(-6, 6))
		get_parent().add_child(e)
	
	get_parent().dummy_dead = true
	get_parent().get_node("Player").hittable_monsters.erase(self)
	get_parent().end_timer = 2.5
	queue_free()
