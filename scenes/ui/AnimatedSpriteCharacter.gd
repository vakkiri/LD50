extends AnimatedSprite

func set_colour(colour):
	material.set_shader_param("colour", colour)
	
func set_char(c):
	frame = ord(c) - ord(' ')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
