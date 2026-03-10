class_name UtilRender
extends Control

var parent: Control
var draw_method_name: String

# Base methods

func set_up(p_parent: Control, p_draw_method_name: String):
	parent = p_parent
	draw_method_name = p_draw_method_name


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if !draw_method_name:
		return
	
	parent.call(draw_method_name, self)
