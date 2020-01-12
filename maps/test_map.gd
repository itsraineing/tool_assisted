extends Node2D

const PLAYER_START: Vector2 = Vector2(59, 59)

const BEAM_CYCLE1: int = 60
const BEAM_CYCLE2: int = 90
const BEAM_TIME: int = 10
const BEAM_START1: int = 0
const BEAM_START2: int = 30

onready var game_master: Node = get_node("/root/game_master")

var current_frame: int = 0

func _ready():
	game_master.register_level(self)

func handle_frame(delta):
	if current_frame % BEAM_CYCLE1 >= BEAM_START1 and current_frame % BEAM_CYCLE1 < (BEAM_START1 + BEAM_TIME):
		$beam1.visible = true
		for area in $beam1col.get_children():
			area.monitoring = true
	else:
		$beam1.visible = false
		for area in $beam1col.get_children():
			area.monitoring = false
	
	if current_frame % BEAM_CYCLE2 >= BEAM_START2 and current_frame % BEAM_CYCLE2 < (BEAM_START2 + BEAM_TIME):
		$beam2.visible = true
		for area in $beam2col.get_children():
			area.monitoring = true
	else:
		$beam2.visible = false
		for area in $beam2col.get_children():
			area.monitoring = false
	
	current_frame += 1

func reset():
	$player.position = PLAYER_START
	$player.reset_status()
	
	current_frame = 0
