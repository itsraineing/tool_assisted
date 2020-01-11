extends KinematicBody2D

const UP: Vector2 = Vector2(0, -1)

const SPRITE_FRAMES: int = 9
const ANIM_IDLE_FRAMES: int = 2
const ANIM_JUMP_FRAMES: int = 1
const ANIM_FALL_FRAMES: int = 1
const ANIM_LOOK_FRAMES: int = 3
const ANIM_DIE_FRAMES: int = 2

const ANIM_IDLE_FRAMETIME: int = 60
const ANIM_RUN_FRAMETIME: int = 10
const ANIM_JUMP_FRAMETIME: int = 0
const ANIM_FALL_FRAMETIME: int = 0

const ANIM_DIE_FRAMETIME: int = 15

const ANIM_LOOK_ACTIVATE_FRAMES: int = 240

enum {DIR_LEFT = -1, DIR_RIGHT = 1}
enum {STATE_IDLE, STATE_WALKING, STATE_JUMPING, STATE_FALLING, STATE_ATTACKING, STATE_HIT, STATE_DEAD, STATE_NONE = -1}
enum {FRAME_IDLE1, FRAME_IDLE2, FRAME_JUMP, FRAME_FALL, FRAME_LOOK1, FRAME_LOOK2, FRAME_LOOK3, FRAME_DIE, FRAME_NONE}
enum {ANIM_IDLE = 0, ANIM_RUN = 621, ANIM_JUMP = 2, ANIM_FALL = 3, ANIM_LOOK = 4, ANIM_DIE = 7}

export (float) var walk_speed = 8000.0
export (float) var walk_acceleration = 1200.0
export (float) var jump_power = 5000
export (int) var max_jump_time = 30
export (float) var in_air_acceleration = 20.0

export (float) var gravity = 20000.0
export (float) var gravity_acceleration = 500.0

onready var game_master: Node = get_node("/root/game_master")

var enable_control: bool = true
var is_alive: bool = true

var is_jumping: bool = false
var remaining_jump_time: int = 0

var last_dir: int = DIR_RIGHT

var last_velocity: Vector2 = Vector2(0,0)

var current_state: int = STATE_NONE
var last_state: int = STATE_NONE

var idle_time: int = 0

var current_anim: int = ANIM_IDLE
var current_anim_frame: int = 0

func _ready():
	set_physics_process(true)
	game_master.register_actor(self)

func _physics_process(delta):
	pass

func handle_frame(delta):
	if is_alive and enable_control:
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
		if Input.is_action_pressed("jump") and remaining_jump_time > 0 and (is_on_floor() or is_jumping):
			velocity_change.y -= jump_power * (remaining_jump_time / 10.0)
			remaining_jump_time -= 1
			is_jumping = true
		else:
			if last_velocity.y < 0:
				last_velocity.y /= 1.5
			velocity_change.y += min(last_velocity.y + gravity_acceleration, gravity)
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
					current_anim = ANIM_IDLE
					current_anim_frame = 0
				STATE_WALKING:
					current_anim = ANIM_RUN
					current_anim_frame = 0
				STATE_JUMPING:
					current_anim = ANIM_JUMP
					current_anim_frame = 0
				STATE_FALLING:
					current_anim = ANIM_FALL
					current_anim_frame = 0
		elif idle_time >= ANIM_LOOK_ACTIVATE_FRAMES and current_anim != ANIM_LOOK:
			current_anim = ANIM_LOOK
			current_anim_frame = 0
		
		animate()
		
		# set up for next frame
		last_velocity = velocity / delta
		last_state = current_state

func animate():
	match current_anim:
		ANIM_IDLE:
			if current_anim_frame >= ANIM_IDLE_FRAMES * ANIM_IDLE_FRAMETIME:
				current_anim_frame = 0
			
			if current_anim_frame < ANIM_IDLE_FRAMETIME:
				$Sprite.frame = ANIM_IDLE
			else:
				$Sprite.frame = ANIM_IDLE + 1
		ANIM_RUN:
			if current_anim_frame >= ANIM_IDLE_FRAMES * ANIM_RUN_FRAMETIME:
				current_anim_frame = 0
			
			if current_anim_frame < ANIM_RUN_FRAMETIME:
				$Sprite.frame = ANIM_IDLE
			else:
				$Sprite.frame = ANIM_IDLE + 1
		ANIM_JUMP:
			$Sprite.frame = ANIM_JUMP
		ANIM_FALL:
			$Sprite.frame = ANIM_FALL
		ANIM_LOOK:
			if idle_time >= ANIM_LOOK_ACTIVATE_FRAMES + ANIM_IDLE_FRAMETIME * 2:
				idle_time = 0
				current_anim = ANIM_IDLE
				current_anim_frame = 0
			else:
				if current_anim_frame >= ANIM_IDLE_FRAMETIME:
					$Sprite.frame = ANIM_LOOK + 1
				else:
					match current_anim_frame:
						33, 34, 35, 36, 45, 46, 47, 48:
							$Sprite.frame = ANIM_LOOK + 2
						_:
							$Sprite.frame = ANIM_LOOK
		ANIM_DIE:
			if current_anim_frame >= ANIM_DIE_FRAMES * ANIM_DIE_FRAMETIME:
				current_anim_frame = 0
			
			if current_anim_frame < ANIM_DIE_FRAMETIME:
				$Sprite.frame = ANIM_DIE
			else:
				$Sprite.frame = ANIM_DIE + 1
	
	current_anim_frame += 1

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
