@tool
@icon ("res://Assets/Window.png")
extends EditorPlugin

var NodeScript = preload("res://addons/window_95/node/CustomNode.gd")
var Icon = preload("res://Assets/Window.png")

func _enter_tree() -> void:
	add_custom_type("Window95", "NinePatchRect", NodeScript, Icon)


func _exit_tree() -> void:
	remove_custom_type("Window95")
