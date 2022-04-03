extends AnimatedSprite

export var colour = "white"


# Called when the node enters the scene tree for the first time.
func _ready():
	animation = colour
	frame = 0
	playing = true
	speed_scale = rand_range(0.8, 1.2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Explosion_animation_finished():
	queue_free()
