extends KinematicBody2D

const UP: Vector2 = Vector2(0, -1)

enum {DIR_LEFT = -1, DIR_RIGHT = 1}
enum {STATE_IDLE, STATE_WALKING, STATE_JUMPING, STATE_FALLING, STATE_ATTACKING, STATE_HIT, STATE_DEAD, STATE_NONE = -1}

export (float) var walk_speed = 8000.0
export (float) var walk_acceleration = 1200.0
export (float) var jump_power = 10.0
export (float) var max_jump_time = 15.0
export (float) var in_air_acceleration = 20.0

export (float) var gravity = 10000.0

var is_jumping: bool = false
var remaining_jump_time: int = max_jump_time

var last_dir: int = DIR_RIGHT

var last_velocity: Vector2 = Vector2(0,0)

var is_falling: bool = false
var is_walking: bool = false

var current_state: int = STATE_NONE
var last_state: int = STATE_NONE

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	var move_dir: Vector2 = get_move_input().normalized()
	var velocity_change: Vector2 = Vector2(0,0)
	var velocity: Vector2
	
	if move_dir.x != 0:
		if move_dir.x == DIR_LEFT:
			if last_velocity.x > -walk_speed:
				velocity_change.x = last_velocity.x - walk_acceleration
			else:
				velocity_change.x = -walk_speed
		elif move_dir.x == DIR_RIGHT:
			if last_velocity.x < walk_speed:
				velocity_change.x = last_velocity.x + walk_acceleration
			else:
				velocity_change.x = walk_speed
	else:
		velocity_change.x = last_velocity.x / 1.4
	
	velocity_change.y += gravity
	
	velocity = velocity_change * delta
	
	velocity = move_and_slide(velocity, UP)
	
	# animation
	if last_dir == DIR_LEFT:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	
	if is_on_floor():
		if move_dir.x == 0:
			current_state = STATE_IDLE
		else:
			current_state = STATE_WALKING
	elif is_jumping:
		current_state = STATE_JUMPING
	else:
		current_state = STATE_FALLING
	
	if current_state != last_state:
		match current_state:
			STATE_IDLE:
				$AnimationPlayer.play("idle", -1, 0.33)
			STATE_WALKING:
				$AnimationPlayer.play("idle", -1, 3)
			STATE_JUMPING:
				$AnimationPlayer.stop()
				$Sprite.frame = 2
			STATE_FALLING:
				$AnimationPlayer.stop()
				$Sprite.frame = 3
	
	# set up for next frame
	last_velocity = velocity_change
	last_state = current_state
	
	print(is_on_floor())

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
