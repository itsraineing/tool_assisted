extends KinematicBody2D

const UP: Vector2 = Vector2(0, -1)

enum {DIR_LEFT = -1, DIR_RIGHT = 1}
enum {STATE_IDLE, STATE_WALKING, STATE_JUMPING, STATE_FALLING, STATE_ATTACKING, STATE_HIT, STATE_DEAD, STATE_NONE = -1}

export (float) var walk_speed = 8000.0
export (float) var walk_acceleration = 1200.0
export (float) var jump_power = 5000
export (int) var max_jump_time = 30
export (float) var in_air_acceleration = 20.0

export (float) var gravity = 8000.0

export (int) var idle_anim2_time = 180

var is_jumping: bool = false
var remaining_jump_time: int = 0

var last_dir: int = DIR_RIGHT

var last_velocity: Vector2 = Vector2(0,0)

var current_state: int = STATE_NONE
var last_state: int = STATE_NONE

var idle_time: int = 0

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	var move_dir: Vector2 = get_move_input().normalized()
	var velocity_change: Vector2 = Vector2(0,0)
	var velocity: Vector2
	
	# left/right move
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
	
	# jump
	if Input.is_action_pressed("jump") and remaining_jump_time > 0:
		velocity_change.y -= jump_power * (remaining_jump_time / 10.0)
		remaining_jump_time -= 1
		is_jumping = true
	else:
		velocity_change.y += gravity
		is_jumping = false
	
	# move player
	velocity = velocity_change * delta
	velocity = move_and_slide(velocity, UP)
	
	if is_on_floor():
		remaining_jump_time = max_jump_time
	
	# animation
	if last_dir == DIR_LEFT:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	
	if is_on_floor():
		if move_dir.x == 0:
			current_state = STATE_IDLE
			idle_time += 1
		else:
			current_state = STATE_WALKING
			idle_time = 0
	elif is_jumping:
		current_state = STATE_JUMPING
		idle_time = 0
	else:
		current_state = STATE_FALLING
		idle_time = 0
	
	if current_state != last_state:
		match current_state:
			STATE_IDLE:
				$AnimationPlayer.play("idle")
			STATE_WALKING:
				$AnimationPlayer.play("idle", -1, 3)
			STATE_JUMPING:
				$AnimationPlayer.stop()
				$Sprite.frame = 2
			STATE_FALLING:
				$AnimationPlayer.stop()
				$Sprite.frame = 3
	elif idle_time >= idle_anim2_time:
		idle_time = 0
		$AnimationPlayer.play("idle2")
	
	# set up for next frame
	last_velocity = velocity_change
	last_state = current_state

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
