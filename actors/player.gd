extends KinematicBody2D

enum {DIR_LEFT = -1, DIR_RIGHT = 1}

export (float) var walk_speed = 200.0
export (float) var walk_acceleration = 400.0
export (float) var jump_power = 10.0
export (float) var max_jump_time = 15.0
export (float) var in_air_acceleration = 20.0

var is_jumping: bool = false
var remaining_jump_time: int = max_jump_time

var last_dir: int = DIR_RIGHT

var last_velocity: Vector2 = Vector2(0,0)

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	var move_dir: Vector2 = get_move_input().normalized()
	var velocity_change: Vector2 
	var velocity: Vector2
	
	if move_dir.x != 0:
		velocity_change.x = last_velocity.x + (move_dir.x * walk_acceleration)
	else:
		velocity_change.x = last_velocity.x / 1.4
	velocity = velocity_change * delta
	
	#velocity = move_dir.normalized() * walk_speed
	
	velocity = move_and_slide(velocity)
	last_velocity = velocity_change

func get_move_input():
	var dir = Vector2(0,0)
	
	if Input.is_action_pressed("left"):
		if Input.is_action_pressed("right"):
			dir.x = -last_dir
		else:
			dir.x = DIR_LEFT
			last_dir = DIR_LEFT
	elif Input.is_action_pressed("right"):
		dir.x = DIR_RIGHT
		last_dir = DIR_RIGHT
	
	return dir
