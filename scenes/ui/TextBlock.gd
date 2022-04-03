extends Node2D

const CHAR = preload("res://scenes/ui/AnimatedSpriteCharacter.tscn")
export var text = "Default ! Text"
export var char_width = 4
export var char_height = 9
export var line_width = 128
export var upper_padding = 1
export var lower_padding = 0
export var space_size = 3
export var vertical_padding = 2
export var immediate = true	# display all text immediately
export var char_timer = 0
var sound = null
var sound_pitch_range = Vector2(1.0, 1.0)
var chars = []
var font_info = {}

export var font = "default_font"
export var colour = Color(1.0, 1.0, 1.0)

var chars_shown = 0
var text_speed = 0.025

func set_colour(new_colour):
	colour = new_colour
	for c in chars:
		c.set_colour(colour)
		
func set_font(font_name):
	font = font_name
	var file = File.new()
	var path = "res://assets/fonts/" + font_name + ".json"

	if file.file_exists(path):
		file.open(path, File.READ)
		font_info = JSON.parse(file.get_as_text()).result	
		file.close()
	else:
		font_info = {}
	
	# TODO: move this all into font_info
	if font_name == "shop_titles":
		char_width = 8
		char_height = 8
		space_size = 3
		upper_padding = 3
		lower_padding = 3
	elif font_name == "default_font":
		char_width = 4
		char_height = 9
		space_size = 3
		upper_padding = 1
		lower_padding = 0
	elif font_name == "ui_large":
		char_width = 8
		char_height = 18
		space_size = 1
		upper_padding = 2
		lower_padding = 2
		
		
func _update_text():
	# TODO for some reason I coded this in a way that re-process the entire
	# string every time a character updates, which seems really unnecessary lol
	for c in chars:
		remove_child(c)
		c.queue_free()
	chars.clear()
	
	var x = 0
	var y = 0
	var pos = 0
	for t in text.substr(0, chars_shown):
		# When we hit a space, we will add a gap (if the next word fits on
		# the same line), or move down a line and reset the horizontal position
		# if not
		if t == " ":
			var space_left = line_width - x
			var next_word_length = space_size
			var start = pos+1
			
			for i in range(start, len(text)):
				if text[i] == " ":
					break
				if text[i] in font_info:
					next_word_length += font_info[text[i]]
				else:
					next_word_length += char_width
				if text[i] >= 'A' and text[i] <= 'Z':
					next_word_length += upper_padding
				else:
					next_word_length += lower_padding
			
			if next_word_length <= space_left:
				x += space_size
			else:
				x = 0
				y += char_height + vertical_padding
		elif t == "\n":
			x = 0
			y += char_height + vertical_padding
		else:
			var c = CHAR.instance()
			c.animation = font
			c.set_char(t)
			c.position.x = x
			c.position.y = y
			chars.append(c)
			add_child(c)
			if t in font_info:
				x += font_info[t]
			else:
				x += char_width
			
			if t >= 'A' and t <= 'Z':
				x += upper_padding
			else:
				x += lower_padding
		pos += 1
			
	set_colour(colour)
	
	
func set_text(new_text):
	text = new_text
	if immediate:
		chars_shown = len(text)
	else:
		chars_shown = 0
	_update_text()
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_font(font)
	if immediate:
		chars_shown = len(text)
	else:
		chars_shown = 0
	_update_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (not immediate) and (chars_shown < len(text)):
		char_timer -= delta
		if char_timer <= 0:
			if sound and text[chars_shown] != " ":
				sound.pitch_scale = rand_range(sound_pitch_range.x, sound_pitch_range.y)
				sound.play()
				char_timer += text_speed
			else:
				char_timer += text_speed * 2.0 # longer pause for spaces
			chars_shown += 1
			_update_text()
