extends Node2D

const SLOT_POS = [Vector2(57, 40), Vector2(178, 40), Vector2(57, 88), Vector2(178, 88)]

onready var game_master: Node = get_node("/root/game_master")
onready var framecounts = [$pause_layer/pause_menu/s1_frames, $pause_layer/pause_menu/s2_frames, $pause_layer/pause_menu/s3_frames, $pause_layer/pause_menu/s4_frames]

var selected_slot: int = 0

func _ready():
	game_master.register_hud(self)
	$pause_layer/pause_menu.visible = false
	$pause_layer/pause_menu/AnimationPlayer.play("blink")
	
	set_physics_process(true)

func set_frame(frame):
	$top_hud/frame.text = String(frame)

func set_playpause(status: int):
	match status:
		0:
			$top_hud/playpause.frame = 0
		1:
			$top_hud/playpause.frame = 1

func toggle_pause_menu():
	if $pause_layer/pause_menu.visible:
		$pause_layer/pause_menu.visible = false
	else:
		$pause_layer/pause_menu.visible = true
		game_master.is_paused = true

func _physics_process(delta):
	if $pause_layer/pause_menu.visible:
		if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
			selected_slot = selected_slot ^ 1
		if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up"):
			selected_slot = selected_slot ^ 2
		
		$pause_layer/pause_menu/select.position = SLOT_POS[selected_slot]
		
		if Input.is_action_just_pressed("pause"):
			game_master.load_state(game_master.save_states[selected_slot])
		elif Input.is_action_just_pressed("frame_advance"):
			game_master.save_state(selected_slot)
			framecounts[selected_slot].text = String(game_master.current_time)
