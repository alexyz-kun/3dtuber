class_name WindowCaptureToLightSourceBridge
extends Node

const DOWNSCALE_SIZE: int = 16
const SECONDS_PER_FRAME_CAPTURE: float = 0.01

var window_capture: WindowCapture
var is_recording: bool
var current_hwnd: int = -1
var current_title: String
var secs_until_next_frame: float

# Base methods

func set_up():
	window_capture = SceneSandbox.instance.window_capture
	
	var pick_window_panel: SideMenuPanelPickWindow = \
		(SceneSandbox.instance.side_menu.menu_pick_window.panel as SideMenuPanelPickWindow)
	pick_window_panel.button_refresh_list.pressed.connect(_on_refresh_list_button_pressed)
	pick_window_panel.button_toggle_recording.pressed.connect(_on_toggle_record_button_pressed)
	pick_window_panel.window_picker_panel.window_picked.connect(_on_window_picked)


func _process(p_delta: float) -> void:
	if is_recording and current_hwnd != -1:
		_handle_recording(p_delta)


# Private methods

func _capture_frame():
	var recorded_texture: ImageTexture = window_capture.get_frame_texture()
	if !recorded_texture:
		return
	
	# Get the texture and downscale it
	var recorded_image: Image = recorded_texture.get_image()
	recorded_image.resize(DOWNSCALE_SIZE, DOWNSCALE_SIZE, Image.INTERPOLATE_NEAREST)
	
	# Average out the colors
	var average_color: Color = recorded_image.get_pixel(0, 0)
	var total_pixels: int = DOWNSCALE_SIZE * DOWNSCALE_SIZE
	for yy in DOWNSCALE_SIZE:
		for xx in DOWNSCALE_SIZE:
			var pixel_color: Color = recorded_image.get_pixel(yy, xx)
			if pixel_color.v < 0.5 or pixel_color.v > 0.9:
				total_pixels -= 1
				continue
			average_color += recorded_image.get_pixel(yy, xx)
	average_color /= float(total_pixels)
	
	# Update scene light source color
	SceneSandbox.instance.light.light_color = average_color


func _handle_recording(p_delta: float):
	if secs_until_next_frame > 0:
		secs_until_next_frame -= p_delta
		return
	secs_until_next_frame = SECONDS_PER_FRAME_CAPTURE
	_capture_frame()


# Signal handling

func _on_window_picked(p_hwnd: int, p_title: String):
	var prev_hwnd: int = current_hwnd
	current_hwnd = p_hwnd
	current_title = p_title
	(SceneSandbox.instance.side_menu.menu_pick_window.panel as SideMenuPanelPickWindow) \
		.captured_window_label.text = "Currently capturing • \"%s\"" % current_title
	
	if is_recording:
		if prev_hwnd != -1:
			window_capture.stop_capture()
		window_capture.start_capture(current_hwnd)
	else:
		# TODO: This does not currently work.
		window_capture.start_capture(current_hwnd)
		_capture_frame()
		window_capture.stop_capture()


func _on_toggle_record_button_pressed():
	is_recording = !is_recording
	(SceneSandbox.instance.side_menu.menu_pick_window.panel as SideMenuPanelPickWindow) \
		.button_toggle_recording.text = "Stop Recording" if is_recording else "Start Recording"
	
	if is_recording and current_hwnd != -1:
		window_capture.start_capture(current_hwnd)
	else:
		window_capture.stop_capture()


func _on_refresh_list_button_pressed():
	var window_list: Array[Dictionary] = window_capture.get_window_list()
	(SceneSandbox.instance.side_menu.menu_pick_window.panel as SideMenuPanelPickWindow) \
		.window_picker_panel.update_list(window_list)
