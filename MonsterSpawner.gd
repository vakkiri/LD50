extends Node2D

var active = true

var spawn_time = 10.0
var spawn_random = 0.1
var spawn_timer = 0.0
var total_time = 0.0
export var initial_time = 10.0
export var spawn_delay = 0.0
export var spawn_speedup = 0.25
var min_spawn_time = 4.0

const DOG = preload("res://scenes/MonsterDog.tscn")
const BIGDOG = preload("res://scenes/MonsterBigDog.tscn")
const RACCOON = preload("res://scenes/MonsterRaccoon.tscn")
const BIGRACCOON = preload("res://scenes/MonsterBigRaccoon.tscn")

var rac_spawn_rate = 5
var big_dog_spawn_rate = 9
var big_rac_spawn_rate = 15
var spawn_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_time = initial_time


func _spawn(type):
	var new_monster = type.instance()
	new_monster.position = position
	if spawn_time > min_spawn_time:
		spawn_time -= spawn_speedup
	else:
		spawn_time = min_spawn_time
	get_parent().add_child(new_monster)
	
	
func _spawn_monster():
	var new_monster = null
	spawn_index += 1
	
	if spawn_index % big_rac_spawn_rate == 0:
		_spawn(BIGRACCOON)
	if spawn_index % big_dog_spawn_rate == 0:
		_spawn(BIGDOG)
	if spawn_index % rac_spawn_rate == 0:
		_spawn(RACCOON)
		
	_spawn(DOG)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		if spawn_delay > 0.0:
			spawn_delay -= delta
		else:
			spawn_timer -= delta
			
			if spawn_timer <= 0.0:
				spawn_timer += spawn_time + rand_range(0.0, spawn_random)
				_spawn_monster()
