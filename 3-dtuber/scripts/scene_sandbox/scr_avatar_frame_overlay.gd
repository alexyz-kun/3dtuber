class_name AvatarFrameOverlay
extends Control

var frame: AvatarFrame

# Base methods

func set_up(p_frame: AvatarFrame):
	frame = p_frame


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if !frame:
		return
	if frame.is_locked:
		return
	
	const LINE_WIDTH: float = 2
	
	var outline_color: Color = UtilColor.AVATAR_FRAME_OUTLINE_DEFAULT
	if frame.is_highlighted and !frame.is_being_resized:
		outline_color = UtilColor.AVATAR_FRAME_OUTLINE_HIGHLIGHTED
	
	var line_radius: float = LINE_WIDTH / 2
	var top_left := Vector2(0, 0) + Vector2(line_radius, line_radius)
	var top_right := Vector2(frame.size.x, 0) + Vector2(-line_radius, line_radius)
	var bottom_left := Vector2(0, frame.size.y) + Vector2(line_radius, -line_radius)
	var bottom_right := frame.size + Vector2(-line_radius, -line_radius)
	
	draw_line(top_left, top_right, outline_color, LINE_WIDTH)
	draw_line(top_right, bottom_right, outline_color, LINE_WIDTH)
	draw_line(bottom_right, bottom_left, outline_color, LINE_WIDTH)
	draw_line(bottom_left, top_left, outline_color, LINE_WIDTH)
