extends TextureRect


const EXPLOSION = preload("res://scenes/Explosion.tscn")
var explosion_time = 0.0
var gen_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	

func show():
	visible = true
	explosion_time = 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if explosion_time > 0.0:
		explosion_time -= delta
		gen_time -= delta
		if gen_time <= 0.0:
			gen_time += 0.1
			randomize()
			var e = EXPLOSION.instance()
			e.position = rect_position + Vector2(rand_range(-4, 16), rand_range(-4, 34))
			get_parent().add_child(e)
