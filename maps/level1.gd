extends Node2D

const PLAYER_START: Vector2 = Vector2(0, 37)

const SECTION1_CYCLE: int = 60
const SECTION1_ON: int = 30
const SECTION1_INITIALDELAY: int = 30

const SECTION2_CYCLE: int = 60
const SECTION2_ON: int = 5
const SECTION2_INITIALDELAY: int = 60

const SECTION3_CYCLE: int = 60
const SECTION3_INITIALDELAY: int = 60

const CASCADE_INITIALDELAY: int = 10

var current_frame: int = 0

var section1_active: bool = false
var section2_active: bool = false
var section3_active: bool = false
var cascade_active: bool = false

var section1_start: int = 0
var section2_start: int = 0
var section3_start: int = 0
var cascade_start: int = 0

var cascade_on: int = 0

var section3_section = 0
var section3_timeonsection = 0

onready var game_master: Node = get_node("/root/game_master")
onready var cascade = [$cascade1, $cascade2, $cascade3, $cascade4, $cascade5, $cascade6, $cascade7, $cascade8, $cascade9, $cascade10]

func _ready():
	game_master.register_level(self)
	for c in cascade:
		for area in c.get_children():
			area.monitoring = false

func handle_frame(delta):
	if current_frame < 5:
		section2_active = false
	
	$beams_cycle1.visible = false
	$beams_cycle1/Area2D.monitoring = false
	
	$beams_cycle2.visible = false
	$beams_cycle2/Area2D.monitoring = false
	
	$beams_final_top.visible = false
	$beams_final_top/Area2D.monitoring = false
	$beams_final_bottom.visible = false
	$beams_final_bottom/Area2D.monitoring = false
	
	if section1_active:
		if current_frame > section1_start + SECTION1_INITIALDELAY:
			$beams_cycle1.visible = true
			$beams_cycle1/Area2D.monitoring = true
	
	if section2_active:
		if current_frame > section2_start + SECTION2_INITIALDELAY and false:
			if (current_frame - section2_start) % SECTION2_CYCLE < SECTION2_ON:
				$beams_cycle2.visible = true
				$beams_cycle2/Area2D.monitoring = true
	
	if section3_active:
		if section3_section == 0:
			$beams_final_top.visible = true
			$beams_final_bottom.visible = false
			$beams_final_top/Area2D.monitoring = true
			$beams_final_bottom/Area2D.monitoring = false
		else:
			$beams_final_top.visible = false
			$beams_final_bottom.visible = true
			$beams_final_top/Area2D.monitoring = false
			$beams_final_bottom/Area2D.monitoring = true
		
		section3_timeonsection += 1
		
		if section3_timeonsection >= SECTION3_CYCLE:
			section3_section = section3_section ^ 1
			section3_timeonsection = 0
	
	if cascade_active:
		if current_frame > cascade_start + CASCADE_INITIALDELAY:
			if current_frame % CASCADE_INITIALDELAY == 0 and cascade_on < 10:
				cascade[cascade_on].visible = true
				for area in cascade[cascade_on].get_children():
					area.monitoring = true
				cascade_on += 1
	
	current_frame += 1

func reset():
	$player.position = PLAYER_START
	$player.reset_status()
	
	current_frame = 0
	section1_active = false
	section1_start = 0
	section2_active = false
	section2_start = 0
	section3_active = false
	section3_start = 0
	cascade_active = false
	cascade_start = 0
	
	cascade_on = 0
	
	section3_section = 0
	section3_timeonsection = 0
	
	for i in range(10):
		cascade[i].visible = false
		for area in cascade[i].get_children():
			area.monitoring = false
	
	$section1_trigger.monitoring = true
	$section2_trigger.monitoring = true
	$section3_trigger.monitoring = true
	$cascade_trigger.monitoring = true

func _on_section1_trigger_body_entered(body):
	if body == $player:
		section1_active = true
		section1_start = current_frame
		$section1_trigger.set_deferred("monitoring", false)

func _on_section2_trigger_body_entered(body):
	if body == $player:
		section2_active = true
		section2_start = current_frame
		$section2_trigger.set_deferred("monitoring", false)

func _on_section3_trigger_body_entered(body):
	if body == $player:
		section3_active = true
		section3_start = current_frame
		$section3_trigger.set_deferred("monitoring", false)

func _on_cascade_trigger_body_entered(body):
	if body == $player:
		cascade_active = true
		cascade_start = current_frame
		$cascade_trigger.set_deferred("monitoring", false)
