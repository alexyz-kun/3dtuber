class_name SideMenu
extends Control

var panel_parent: Control
var menu_adjust_camera_lighting: SideMenuItem
var menu_pick_window: SideMenuItem
# 🍱 Private
var _menu_list: Array[SideMenuItem]

# Base methods

func set_up():
	panel_parent = $PanelList
	
	menu_adjust_camera_lighting = SideMenuItem.new(
		self,
		$PanelList/PanelAdjustCameraLighting,
		$ButtonList/ButtonAdjustCameraLighting
	)
	menu_pick_window = SideMenuItem.new(
		self,
		$PanelList/PanelPickWindow,
		$ButtonList/ButtonPickWindow
	)
	
	_menu_list.append(menu_adjust_camera_lighting)
	_menu_list.append(menu_pick_window)
	
	(menu_adjust_camera_lighting.panel as SideMenuPanelAdjustCameraLighting).set_up()
	(menu_pick_window.panel as SideMenuPanelPickWindow).set_up()


# Private methods

func _open_menu(p_menu_panel_id: int):
	var menu_to_open: SideMenuItem
	for menu in _menu_list:
		menu.panel.visible = false
		if menu.panel.get_instance_id() == p_menu_panel_id:
			menu_to_open = menu
	menu_to_open.panel.visible = true


# Subclasses

class SideMenuItem:
	var parent: SideMenu
	var panel: Control
	var button: Button
	
	# Base methods
	
	func _init(p_parent: SideMenu, p_panel: Control, p_button: Button):
		parent = p_parent
		panel = p_panel
		button = p_button
		
		button.pressed.connect(_on_button_pressed)
	
	
	# Signal handling
	
	func _on_button_pressed():
		# NOTE: Special case of calling a different node's private method.
		parent._open_menu(panel.get_instance_id())
