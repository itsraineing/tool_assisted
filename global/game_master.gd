extends Node

const DELTA: float = 1.0 / 60.0

var current_time: int = 0
var recorded_time: int = 0
var is_paused: bool = false
var ingame: bool = true
var is_replay: bool = false

var actors = []

var tophud: Node
var current_level: Node

var player_inputs = []

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if ingame:
		if Input.is_action_just_pressed("pause"):
			is_paused = not is_paused
		
		if Input.is_action_just_pressed("replay"):
			is_replay = true
			current_time = 0
		
		if is_replay:
			if current_time == 0:
				current_level.reset()
			
			if current_time == recorded_time:
				is_replay = false
				is_paused = true
			else:
				if not is_paused or Input.is_action_just_pressed("frame_advance"):
					tophud.set_frame(current_time)
					
					current_level.handle_frame(DELTA)
					
					for i in range(actors.size()):
						actors[i].handle_frame(DELTA)
					
					current_time += 1
		else:
			if not is_paused or Input.is_action_just_pressed("frame_advance"):
				tophud.set_frame(current_time)
				
				current_level.handle_frame(DELTA)
				
				for i in range(actors.size()):
					actors[i].handle_frame(DELTA)
				
				recorded_time = current_time
				current_time += 1
		
		tophud.set_playpause(int(is_paused))

func register_actor(actor: Node):
	actors.append(actor)

func remove_actor(actor: Node):
	var i = actors.find(actor)
	actors.remove(i)

func register_tophud(n: Node):
	tophud = n

func register_level(level: Node):
	current_level = level

func remove_tophud():
	tophud = null

func add_playerinput(input: int):
	player_inputs.append(input)

func get_current_time():
	return current_time

func get_isreplay():
	return is_replay

func get_currentframeinput():
	return player_inputs[current_time]
