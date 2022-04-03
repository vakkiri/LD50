extends CanvasLayer


var messages = []
var actions = []
var next_speaker = "right"
var index = 0

var active_modulate = Color(1.0, 1.0, 1.0, 1.0)
var inactive_modulate = Color(1.0, 1.0, 1.0, 0.65)

var portraits = {
	"gator": load("res://assets/ui/gatorportrait.png"),
	"cat": load("res://assets/ui/catportrait.png"),
}
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	$LeftText.set_text("")
	$RightText.set_text("")
	$RightPortrait.self_modulate = inactive_modulate
	$RightPortraitBG.self_modulate = inactive_modulate
	$RightText.self_modulate = inactive_modulate
	$RightTextBG.self_modulate = inactive_modulate
	$LeftPortrait.self_modulate = inactive_modulate
	$LeftPortraitBG.self_modulate = inactive_modulate
	$LeftText.self_modulate = inactive_modulate
	$LeftTextBG.self_modulate = inactive_modulate
	$RightPortrait.visible = false
	$LeftPortrait.visible = false
	$LeftText.sound = TextSound
	$LeftText.sound_pitch_range = Vector2(1.5, 1.5)
	$RightText.sound = TextSound
	$RightText.sound_pitch_range = Vector2(1.5, 1.5)


func conditions_met(conditions):
	for condition in conditions:
		if GameState.get_condition(condition) != conditions[condition]:
			return false
	return true


func init(script_name):
	var file_path = "res://assets/text/" + script_name + ".json"
	var f = File.new()
	f.open(file_path, f.READ)
	var script_dicts = JSON.parse(f.get_as_text()).result
	for script_dict in script_dicts.values():
		if conditions_met(script_dict["conditions"]):
			if "messages" in script_dict:
				messages = script_dict["messages"]
			if "actions" in script_dict:
				actions = script_dict["actions"]
			break
	f.close()
	

func set_condition(args):
	GameState.dialogue_conditions[args["name"]] = args["value"]
	
	
func open_shop(args):
	get_tree().get_root().find_node("World", true, false).active_area.show_shop()
	

func enable_elevator(args):
	# This relies on the npc being in the same area as the elevator
	get_parent().get_node("Elevator").enabled = true
	
	
func set_portrait():
	if messages[index]["side"] == "right":
		$RightPortrait.visible = true
		$RightPortrait.texture = portraits[messages[index]["speaker"]]
	elif messages[index]["side"] == "left":
		$LeftPortrait.texture = portraits[messages[index]["speaker"]]
		$LeftPortrait.visible = true


func trigger_action(action):
	call(action["action"], action["args"])
	
	
func end():
	# It's important to unpause before triggering actions,
	# otherwise we will undo pauses set by alerts
	get_tree().paused = false
	for action in actions:
		trigger_action(action)
	queue_free()


func load_left():
	$LeftText.set_text(messages[index]["message"])
	activate_left()
	
	
func load_right():
	$RightText.set_text(messages[index]["message"])
	activate_right()
	

func activate_right():
	$RightPortrait.self_modulate = active_modulate
	$RightPortraitBG.self_modulate = active_modulate
	$RightText.self_modulate = active_modulate
	$RightTextBG.self_modulate = active_modulate
	$LeftPortrait.self_modulate = inactive_modulate
	$LeftPortraitBG.self_modulate = inactive_modulate
	$LeftText.self_modulate = inactive_modulate
	$LeftTextBG.self_modulate = inactive_modulate
	$RightNext.visible = true
	$LeftNext.visible = false


func activate_left():
	$RightPortrait.self_modulate = inactive_modulate
	$RightPortraitBG.self_modulate = inactive_modulate
	$RightText.self_modulate = inactive_modulate
	$RightTextBG.self_modulate = inactive_modulate
	$LeftPortrait.self_modulate = active_modulate
	$LeftPortraitBG.self_modulate = active_modulate
	$LeftText.self_modulate = active_modulate
	$LeftTextBG.self_modulate = active_modulate
	$LeftNext.visible = true
	$RightNext.visible = false


func load_message():
	if index < len(messages):
		var message = messages[index]
		if message["side"] == "left":
			load_left()
		else:
			load_right()
		set_portrait()
	else:
		end()
	index += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("dialogue_next") or index == 0:
		load_message()
