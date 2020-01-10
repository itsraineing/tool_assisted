extends Node

class Action:
	var actor: Node
	var event: String
	var time: int

const DELTA: float = 1.0 / 60.0

var current_time: int = 0
var actions = []
var save_states = []
var is_paused = false

var actors = []

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused
	
	if not is_paused or Input.is_action_just_pressed("frame_advance"):
		current_time += 1
		for i in range(actors.size()):
			actors[i].handle_frame(DELTA)

func register_actor(actor: Node):
	actors.append(actor)

func remove_actor(actor: Node):
	var i = actors.find(actor)
	actors.remove(i)

func record_action(action: Action):
	actions.append(action)
