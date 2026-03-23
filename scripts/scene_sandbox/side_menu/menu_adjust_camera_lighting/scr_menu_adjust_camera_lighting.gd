class_name SideMenuPanelAdjustCameraLighting
extends Control

var setting_camera_fov := SettingCameraFOV.new()
var setting_camera_distance := SettingCameraDistance.new()
var setting_light := SettingLight.new()

var _light_distance: float

# Base methods

func set_up():	
	setting_camera_fov		.set_up(self, $SliderList/SliderFOV, int(SceneSandbox.instance.camera.fov))
	setting_camera_distance	.set_up(self, $SliderList/SliderDistance, SceneSandbox.instance.camera.global_position.z)
	setting_light			.set_up(self, $SliderList/SliderLight, _get_initial_light_angle())


# Helper

func _get_initial_light_angle() -> float:
	var light_pos: Vector3 = SceneSandbox.instance.light.global_position
	_light_distance = light_pos.length()
	
	var initial_light_angle: float = rad_to_deg(atan2(light_pos.x, light_pos.z))
	if initial_light_angle < 0:
		initial_light_angle += 360
	
	return initial_light_angle


# Subclasses

class SettingCameraFOV:
	var parent: SideMenuPanelAdjustCameraLighting
	var node: Control
	var label_fov: Label
	var slider: HSlider
	var fov: float
	
	func set_up(p_parent: SideMenuPanelAdjustCameraLighting, p_node: Control, p_initial_fov: int):
		parent = p_parent
		node = p_node
		
		label_fov = node.get_node("VBoxContainer/Label")
		slider = node.get_node("VBoxContainer/HSlider")
		
		fov = p_initial_fov
		slider.value = fov
		_on_value_changed(fov)
		
		slider.value_changed.connect(_on_value_changed)
	
	
	# Private methods
	
	func _on_value_changed(p_new_value: float):
		fov = p_new_value
		SceneSandbox.instance.camera.fov = fov
		label_fov.text = "Camera FOV (%d°)" % fov


class SettingCameraDistance:
	var parent: SideMenuPanelAdjustCameraLighting
	var node: Control
	var label_distance: Label
	var slider: HSlider
	var distance: float
	
	func set_up(p_parent: SideMenuPanelAdjustCameraLighting, p_node: Control, p_initial_distance: float):
		parent = p_parent
		node = p_node
		
		label_distance = node.get_node("VBoxContainer/Label")
		slider = node.get_node("VBoxContainer/HSlider")
		
		distance = p_initial_distance
		slider.value = distance
		_on_value_changed(distance)
		
		slider.value_changed.connect(_on_value_changed)
	
	
	# Private methods
	
	func _on_value_changed(p_new_value: float):
		distance = p_new_value
		SceneSandbox.instance.camera.global_position.z = distance
		label_distance.text = "Camera Distance (%.2f m)" % distance


class SettingLight:
	var parent: SideMenuPanelAdjustCameraLighting
	var node: Control
	var label_angle: Label
	var slider: HSlider
	var angle: float
	
	func set_up(p_parent: SideMenuPanelAdjustCameraLighting, p_node: Control, p_initial_angle: float):
		parent = p_parent
		node = p_node
		
		label_angle = node.get_node("VBoxContainer/Label")
		slider = node.get_node("VBoxContainer/HSlider")
		
		angle = p_initial_angle
		slider.value = angle
		_on_value_changed(angle)
		
		slider.value_changed.connect(_on_value_changed)
	
	
	# Private methods
	
	func _on_value_changed(p_new_value: float):
		angle = p_new_value
		var angle_rad: float = deg_to_rad(angle)
		# NOTE: Special case for calling another node's private method
		SceneSandbox.instance.light.global_position = parent._light_distance * Vector3(cos(angle_rad), 0, sin(angle_rad))
		label_angle.text = "Light Position (%d°)" % angle
