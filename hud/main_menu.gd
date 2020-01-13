extends Node2D

const BUTTON_POSITIONS = [Vector2(120, 73), Vector2(120, 102), Vector2(120, 132)]

onready var game_master: Node = get_node("/root/game_master")

var credits_open: bool = false
var selected_button: int = 0

var level1 = preload("res://base.tscn")

func _ready():
	$AnimationPlayer.play("blink")
	set_physics_process(true)
	pass

func _physics_process(delta):
	if credits_open:
		if Input.is_action_just_pressed("frame_advance") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("pause"):
			credits_open = false
			$credits.visible = false
	else:
		if Input.is_action_just_pressed("down"):
			selected_button = (selected_button + 1) % 3
		if Input.is_action_just_pressed("up"):
			selected_button = (selected_button - 1) % 3
		
		$select.position = BUTTON_POSITIONS[selected_button]
		
		if Input.is_action_just_pressed("frame_advance") or Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("pause"):
			match selected_button:
				0:
					#get_tree().get_root().add_child(level1)
					get_tree().change_scene_to(level1)
					game_master.ingame = true
					self.queue_free()
				1:
					credits_open = true
					$credits.visible = true
				2: 
					get_tree().quit()
