extends Node2D


export var base_cost = 10
export var cost_multiplier = 1.1
export var max_level = 5
var player = null
var level = 0
var cost = 0
export var skill = "speed"

# Called when the node enters the scene tree for the first time.
func _ready():
	cost = base_cost
	$CostText.set_text(str(cost))
	$PurchaseIndicator.visible = false

func increase_cost():
	cost = min(999, int(cost * cost_multiplier))
	$CostText.set_text(str(cost))
	level += 1
	if level >= max_level:
		visible = false
	

func upgrade():
	if player.coins >= cost and visible:
		player.coins -= cost
		increase_cost()
		if skill == "speed":
			player.MAX_VELOCITY.x += 10.0
		elif skill == "attackspeed":
			player.attack_speed -= 0.05
		elif skill == "attack":
			player.attack_damage += 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null and Input.is_action_just_pressed("player_down"):
		upgrade()


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$PurchaseIndicator.visible = true
		player = body


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$PurchaseIndicator.visible = false
		player = null
