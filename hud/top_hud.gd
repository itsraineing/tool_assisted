extends CanvasLayer

onready var game_master: Node = get_node("/root/game_master")

func _ready():
	game_master.register_tophud(self)

func set_frame(frame: int):
	$frame.text = String(frame)

func set_playpause(status: int):
	match status:
		0:
			$playpause.frame = 0
		1:
			$playpause.frame = 1
