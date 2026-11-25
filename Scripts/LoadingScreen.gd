extends Control

func _ready() -> void:
	if true: get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")
	else:
		await get_tree().create_timer(2).timeout
		var UncoverTween = create_tween()
		UncoverTween.tween_property($"Cover", "modulate:a", 0, 1)
		UncoverTween.play()
		await get_tree().create_timer(5).timeout
		var CoverTween = create_tween()
		CoverTween.tween_property($"Cover", "modulate:a", 1, 1)
		CoverTween.play()
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")
	