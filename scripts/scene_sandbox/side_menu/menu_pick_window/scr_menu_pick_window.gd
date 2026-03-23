class_name SideMenuPanelPickWindow
extends Control

var window_picker_panel: WindowPickerPanel
var button_refresh_list: Button
var button_toggle_recording: Button
var captured_window_label: Label

# Base methods

func set_up():
	window_picker_panel = $VBoxContainer/WindowPickerPanel
	button_refresh_list = $VBoxContainer/ButtonRow/ButtonRefreshList
	button_toggle_recording = $VBoxContainer/ButtonRow/ButtonToggleRecording
	captured_window_label = $VBoxContainer/CapturedWindowLabel
	
	window_picker_panel.set_up()
	
	button_refresh_list.pressed.connect(_on_button_refresh_list_pressed)


# Signal handling

func _on_button_refresh_list_pressed():
	window_picker_panel.update_list(SceneSandbox.instance.window_capture.get_window_list())
