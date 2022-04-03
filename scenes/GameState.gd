extends Node

var difficulty = "normal"

var dialogue_conditions = {
}


func get_condition(cond):
	if cond in dialogue_conditions:
		return dialogue_conditions[cond]
	else:
		return null
