extends Node

class Action:
	var actor: Node
	var event: String
	var time: int

var current_time: int = 0
var actions = []
var save_states = []
var is_paused = false

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if !is_paused:
		current_time += 1

func record_action(action: Action):
	actions.append(action)
