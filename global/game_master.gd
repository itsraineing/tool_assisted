extends Node

class Action:
	var actor: Node
	var action: String
	var time: int

var current_time: int = 0
var actions = []
var save_states = []

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	current_time += 1

func record_action(action: Action):
	actions.append(action)
