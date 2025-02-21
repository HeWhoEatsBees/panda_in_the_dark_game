extends Node2D

@onready var pause_menu: Control = $panda/Camera2D/pause_menu
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_menu.hide()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		PauseMenu()

func PauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused
