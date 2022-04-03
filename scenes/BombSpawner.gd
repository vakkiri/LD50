extends Node2D

const BOMB = preload("res://scenes/BombItem.tscn")

var spawn_chance = 0.1
var spawn_interval = 10.0
var spawn_timer = 30.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawn_timer -= delta
	if spawn_timer <= 0:
		if rand_range(0.0, 1.0) <= spawn_chance:
			var b = BOMB.instance()
			b.position = position - Vector2(4.0, 8.0)
			get_parent().add_child(b)
		spawn_timer += spawn_interval
