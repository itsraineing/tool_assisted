extends Node

const DELTA: float = 1.0 / 60.0

var current_time: int = 0
var recorded_time: int = 0
var is_paused: bool = false
var ingame: bool = false
var is_replay: bool = false
var pause_menu_open: bool = false

var actors = []

var hud: Node
var current_level: Node

var player_inputs = []

var save_states = []

func _ready():
	set_physics_process(true)
	
	save_states.resize(4)
	for i in range(0, 4):
		save_states[i] = {}

func _physics_process(delta):
	if ingame:
		if Input.is_action_just_pressed("pause") and not pause_menu_open:
			is_paused = not is_paused
		
		if Input.is_action_just_pressed("replay") and not pause_menu_open:
			is_replay = true
			current_time = 0
		
		if Input.is_action_just_pressed("menu"):
			hud.toggle_pause_menu()
			pause_menu_open = not pause_menu_open
		
		if not pause_menu_open:
			handle_frame()

func save_state(slot: int):
	if slot >= 0 and slot < 4:
		save_states[slot]["current_time"] = current_time
		save_states[slot]["recorded_time"] = recorded_time
		save_states[slot]["player_inputs"] = player_inputs
		save_states[slot]["player_status"] = actors[0].get_status()

func load_state(state: Dictionary):
	if not state.empty():
		current_time = state["current_time"]
		recorded_time = state["recorded_time"]
		player_inputs = state["player_inputs"]
		actors[0].load_status(state["player_status"])

func replay_to_frame(f: int):
	current_time = 0
	
	while current_time < f:
		handle_frame()

func handle_frame():
	if is_replay:
		if current_time == 0:
			current_level.reset()
		
		if current_time == recorded_time:
			is_replay = false
			is_paused = true
		else:
			if not is_paused or Input.is_action_just_pressed("frame_advance"):
				var frame_str = "{cur} / {tot}"
				hud.set_frame(frame_str.format({"cur": current_time, "tot": recorded_time}))
				
				current_level.handle_frame(DELTA)
				
				for i in range(actors.size()):
					actors[i].handle_frame(DELTA)
				
				if not is_replay: # if new input at current frame
					recorded_time = current_time
				
				current_time += 1
	else:
		if not is_paused or Input.is_action_just_pressed("frame_advance"):
			hud.set_frame(current_time)
			
			current_level.handle_frame(DELTA)
			
			for i in range(actors.size()):
				actors[i].handle_frame(DELTA)
			
			recorded_time = current_time
			current_time += 1
	
	hud.set_playpause(int(is_paused))

func register_actor(actor: Node):
	actors.append(actor)

func remove_actor(actor: Node):
	var i = actors.find(actor)
	actors.remove(i)

func register_hud(n: Node):
	hud = n

func register_level(level: Node):
	current_level = level

func remove_tophud():
	hud = null

func add_playerinput(input: int):
	player_inputs.insert(current_time, input)

func clear_playerinput_after_now():
	player_inputs.resize(current_time)

func get_current_time():
	return current_time

func get_isreplay():
	return is_replay

func get_currentframeinput():
	if current_time >= player_inputs.size():
		return 0
	else:
		return player_inputs[current_time]

func get_savestate_frame(slot: int):
	if save_states[slot] != null:
		return save_states[slot]["current_time"]
	else:
		return 0

func reset():
	current_time = 0
	recorded_time = 0
	player_inputs.resize(0)
	current_level.reset()
	ingame = true
	is_paused = false
