class_name WindowPickerPanel
extends Control

signal window_picked(p_hwnd: int, p_title: String)

var item_list: Array[WindowPickerItemButton]
# Components
var vbox_container: VBoxContainer
var empty_list_label: RichTextLabel
# Prefabs
var prefab_window_picker_item_button: PackedScene

# Base methods

func set_up() -> void:
	vbox_container = $MarginContainer/ScrollContainer/VBoxContainer
	empty_list_label = $MarginContainer/EmptyListLabel
	prefab_window_picker_item_button = load(SceneMain.instance.manager.resource.prefab.window_picker_item_button)
	
	SceneMain.instance.manager.input.rmb_pressed.connect(_on_rmb_pressed)


# Public methods

func update_list(p_window_list: Array[Dictionary]):
	for item in item_list:
		item.pressed.disconnect(_on_item_picked)
		item.queue_free()
	item_list.clear()
	
	if p_window_list.size() == 0:
		empty_list_label.visible = true
		return
	empty_list_label.visible = false
	
	for window in p_window_list:
		var new_button: WindowPickerItemButton = prefab_window_picker_item_button.instantiate()
		vbox_container.add_child(new_button)
		new_button.set_up(window.hwnd, window.title)
		
		new_button.pressed.connect(_on_item_picked.bind(window.hwnd, window.title))
		
		item_list.append(new_button)


# Signal handling

func _on_item_picked(p_hwnd: int, p_title: String):
	window_picked.emit(p_hwnd, p_title)


func _on_rmb_pressed():
	visible = !visible
