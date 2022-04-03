extends Node2D

const EXPLOSION = preload("res://scenes/Explosion.tscn")
var life = 1.5
var hit_monsters = []
var damage = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	for c in get_children():
		if c.name != "Area2D":
			c.emitting = true
	for i in range(25):
		var e = EXPLOSION.instance()
		e.position = position + Vector2(rand_range(-32, 32), rand_range(-8, 8))
		if rand_range(0, 1) < 0.5:
			e.colour = "orange"
		get_parent().add_child(e)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	life -= delta
	if life <= 0:
		queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("monster") and not (body in hit_monsters):
		body.hit(damage)
		hit_monsters.append(body)
