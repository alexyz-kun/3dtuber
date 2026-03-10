class_name AvatarFrame
extends Control

const MINIMUM_FRAME_SIZE := Vector2(100, 100)

var image: TextureRect
var overlay: AvatarFrameOverlay
var label_pos: Label
var audio_intensity_bar: ProgressBar

var is_locked: bool
var is_highlighted: bool
var is_being_moved: bool
var is_being_resized: bool
var ui_is_visible: bool = true
var cursor_offset: Vector2
var resizer := Resizer.new()

# Base methods

func set_up():
	image = $Image
	overlay = $Overlay
	label_pos = $LabelPos
	audio_intensity_bar = $AudioIntensityBar
	
	SceneMain.instance.manager.input.lmb_pressed.connect(_on_lmb_pressed)
	SceneMain.instance.manager.input.lmb_released.connect(_on_lmb_released)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	overlay.set_up(self)
	resizer.set_up($Resizers, self)


func _process(p_delta: float) -> void:
	if !is_locked and is_being_moved:
		_drag_frame()
	
	resizer.tick(p_delta)
	_update_pos_label()
	_update_audio_intensity_bar()


# Public methods

func toggle_ui(p_ui_is_visible: bool):
	ui_is_visible = p_ui_is_visible
	is_locked = !p_ui_is_visible		# TODO: Should probably refactor this
	
	overlay.visible = ui_is_visible
	audio_intensity_bar.visible = ui_is_visible
	label_pos.visible = ui_is_visible
	
	resizer.toggle(ui_is_visible)


func get_center() -> Vector2:
	return global_position + size / 2


# Private methods

func _drag_frame():
	var mouse_pos: Vector2 = SceneSandbox.instance.get_viewport().get_mouse_position()
	global_position = mouse_pos - cursor_offset


func _update_audio_intensity_bar():
	var raw_intensity: float = SceneSandbox.instance.audio_stream_recorder.get_audio_volume()
	var intensity: float = inverse_lerp(-70, -30, raw_intensity)
	audio_intensity_bar.value = 100 * intensity


func _update_pos_label():
	label_pos.text = "(%d, %d)" % [global_position.x, global_position.y]


#region Signal handling

func _on_lmb_pressed():
	# Start dragging
	if is_highlighted:
		is_being_moved = true
		var mouse_pos: Vector2 = SceneSandbox.instance.get_viewport().get_mouse_position()
		cursor_offset = mouse_pos - global_position


func _on_lmb_released():
	# Stop dragging
	is_being_moved = false


func _on_mouse_entered():
	is_highlighted = true


func _on_mouse_exited():
	is_highlighted = false


#endregion

# Subclasses

class Resizer:
	var node: Control
	var frame: AvatarFrame
	
	var top_right := Draggable.new()
	var top_left := Draggable.new()
	var bottom_right := Draggable.new()
	var bottom_left := Draggable.new()
	
	var is_on: bool = true
	
	# Base methods
	
	func set_up(p_node: Control, p_frame: AvatarFrame):
		node = p_node
		frame = p_frame
		
		top_right.set_up	(frame, Draggable.Axis.XY, Vector2(1, 1), node.find_child("TopRight"))
		top_left.set_up		(frame, Draggable.Axis.XY, Vector2(0, 1), node.find_child("TopLeft"))
		bottom_right.set_up	(frame, Draggable.Axis.XY, Vector2(1, 0), node.find_child("BottomRight"))
		bottom_left.set_up	(frame, Draggable.Axis.XY, Vector2(0, 0), node.find_child("BottomLeft"))
	
	
	func tick(p_delta: float):
		top_right.tick(p_delta)
		top_left.tick(p_delta)
		bottom_right.tick(p_delta)
		bottom_left.tick(p_delta)
	
	# Public methods
	
	func toggle(p_is_on: bool):
		is_on = p_is_on
		top_right.toggle(is_on)
		top_left.toggle(is_on)
		bottom_left.toggle(is_on)
		bottom_right.toggle(is_on)


class Draggable:
	enum Axis {
		XY,
		X,
		Y
	}
	
	var node: TextureRect
	var frame: AvatarFrame
	
	var axis: Axis
	var pos_t: Vector2
	var node_radius: float
	
	var is_on: bool = true
	var is_hovered: bool
	var is_being_dragged: bool
	
	var drag_start_frame_pos: Vector2
	var drag_start_frame_size: Vector2
	var drag_start_pos: Vector2
	
	var cursor_offset: Vector2
	
	# Base methods
	
	func set_up(p_frame: AvatarFrame, p_axis: Axis, p_pos_t: Vector2, p_node: TextureRect):
		node = p_node
		frame = p_frame
		axis = p_axis
		pos_t = p_pos_t
		
		node_radius = 0.5 * node.size.x
		
		_reposition()
		
		SceneMain.instance.manager.input.lmb_pressed.connect(_on_lmb_pressed)
		SceneMain.instance.manager.input.lmb_released.connect(_on_lmb_released)
		
		p_node.mouse_entered.connect(_on_mouse_entered)
		p_node.mouse_exited.connect(_on_mouse_exited)
		frame.resized.connect(_reposition)
	
	
	func tick(_p_delta: float):
		if is_being_dragged:
			_drag()
	
	
	# Public methods
	
	func toggle(p_is_on: bool):
		is_on = p_is_on
		node.visible = is_on
		
		if !is_on:
			_stop_dragging()
	
	
	# Private methods
	
	func _drag():
		var mouse_pos: Vector2 = SceneSandbox.instance.get_viewport().get_mouse_position()
		var drag_curr_pos: Vector2 = mouse_pos - cursor_offset
		var drag_distance: Vector2 = drag_curr_pos - drag_start_pos
		
		var target_node_pos: Vector2
		var target_frame_pos: Vector2
		var target_frame_size: Vector2
		
		# Case 1 | Bottom-right node, easiest case
		if pos_t.x > 0.5 and pos_t.y > 0.5:
			target_node_pos = drag_curr_pos.max(
				frame.global_position + MINIMUM_FRAME_SIZE - node_radius * Vector2.ONE)
			target_frame_pos = frame.global_position
			target_frame_size = (drag_start_frame_size + drag_distance).max(MINIMUM_FRAME_SIZE)
		
		# Case 2 | Top-right
		elif pos_t.x > 0.5 and pos_t.y < 0.5:
			target_node_pos = Vector2(
				max(drag_curr_pos.x, drag_start_frame_pos.x + MINIMUM_FRAME_SIZE.x - node_radius),
				min(drag_curr_pos.y, drag_start_frame_pos.y - MINIMUM_FRAME_SIZE.y - node_radius + drag_start_frame_size.y))
			target_frame_pos = Vector2(
				frame.global_position.x,
				target_node_pos.y + node_radius)
			target_frame_size = Vector2(
				target_node_pos.x - drag_start_frame_pos.x + node_radius,
				drag_start_frame_size.y + (drag_start_pos.y - target_node_pos.y))
		
		# Case 3 | Bottom-left
		elif pos_t.x < 0.5 and pos_t.y > 0.5:
			target_node_pos = Vector2(
				min(drag_curr_pos.x, drag_start_frame_pos.x - MINIMUM_FRAME_SIZE.x - node_radius + drag_start_frame_size.x),
				max(drag_curr_pos.y, drag_start_frame_pos.y + MINIMUM_FRAME_SIZE.y - node_radius))
			target_frame_pos = Vector2(
				target_node_pos.x + node_radius,
				frame.global_position.y)
			target_frame_size = Vector2(
				drag_start_frame_size.x + (drag_start_pos.x - target_node_pos.x),
				target_node_pos.y - drag_start_frame_pos.y + node_radius)
		
		# Case 4 | Top-left
		else:
			target_node_pos = Vector2(
				min(drag_curr_pos.x, drag_start_frame_pos.x - MINIMUM_FRAME_SIZE.x - node_radius + drag_start_frame_size.x),
				min(drag_curr_pos.y, drag_start_frame_pos.y - MINIMUM_FRAME_SIZE.y - node_radius + drag_start_frame_size.y))
			target_frame_pos = Vector2(
				target_node_pos.x + node_radius,
				target_node_pos.y + node_radius)
			target_frame_size = Vector2(
				drag_start_frame_size.x + (drag_start_pos.x - target_node_pos.x),
				drag_start_frame_size.y + (drag_start_pos.y - target_node_pos.y))
		
		node.global_position = target_node_pos
		frame.global_position = target_frame_pos
		frame.size = target_frame_size
		
		SceneSandbox.instance.avatar_subviewport.size = target_frame_size
	
	
	func _stop_dragging():
		is_being_dragged = false
		frame.is_being_resized = false
		_reposition()
		
		if !is_hovered:
			node.self_modulate = UtilColor.AVATAR_FRAME_OUTLINE_DEFAULT
	
	
	func _reposition():
		# The repositioning should only be applied to nodes that
		# aren't currently dictating the size of the avatar frame
		if is_being_dragged:
			return
		
		var target_pos := Vector2(
			lerpf(0, frame.size.x, pos_t.x),
			lerpf(0, frame.size.y, pos_t.y))
		var offset: Vector2 = 0.5 * node.size
		node.position = target_pos - offset
	
	
	# Signal handling
	
	func _on_lmb_pressed():
		if !is_on:
			return
		if !is_hovered:
			return
		
		# Start dragging
		is_being_dragged = true
		frame.is_being_resized = true
		
		var mouse_pos: Vector2 = SceneSandbox.instance.get_viewport().get_mouse_position()
		cursor_offset = mouse_pos - node.global_position
		
		drag_start_pos = node.global_position
		drag_start_frame_pos = frame.global_position
		drag_start_frame_size = frame.size
	
	
	func _on_lmb_released():
		_stop_dragging()
	
	
	func _on_mouse_entered():
		is_hovered = true
		
		if !frame.is_being_resized and !is_being_dragged:
			node.self_modulate = UtilColor.AVATAR_FRAME_OUTLINE_HIGHLIGHTED
	
	
	func _on_mouse_exited():
		is_hovered = false
		
		if !is_being_dragged:
			node.self_modulate = UtilColor.AVATAR_FRAME_OUTLINE_DEFAULT
