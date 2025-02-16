extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://pure_dark_main/Scenes/Levels/001_opening_scene.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
