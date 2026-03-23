class_name WindowPickerItemButton
extends Button

var window_hwnd: int
var window_title: String

# Base methods

func set_up(p_hwnd: int, p_title: String) -> void:
	window_hwnd = p_hwnd
	window_title = p_title
	text = "%s" % window_title
