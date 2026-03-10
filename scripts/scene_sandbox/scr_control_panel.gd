class_name ControlPanel
extends Control

var control_fov: ControlFOV
var control_distance: ControlDistance
var control_light: ControlLight

var light_distance: float

# Base methods

func set_up():
	control_fov = ControlFOV.new()
	control_distance = ControlDistance.new()
	control_light = ControlLight.new()
	
	control_fov.set_up(self, $VBoxContainer/SliderFOV, int(SceneSandbox.instance.camera.fov))
	control_distance.set_up(self, $VBoxContainer/SliderDistance, SceneSandbox.instance.camera.global_position.z)
	
	var light_pos: Vector3 = SceneSandbox.instance.light.global_position
	light_distance = light_pos.length()
	var initial_light_angle: float = rad_to_deg(atan2(light_pos.x, light_pos.z))
	if initial_light_angle < 0:
		initial_light_angle += 360
	control_light.set_up(self, $VBoxContainer/SliderLight, initial_light_angle)


# Subclasses

class ControlFOV:
	var parent: ControlPanel
	var node: Control
	var label_fov: Label
	var slider: HSlider
	var fov: float
	
	func set_up(p_parent: ControlPanel, p_node: Control, p_initial_fov: int):
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


class ControlDistance:
	var parent: ControlPanel
	var node: Control
	var label_distance: Label
	var slider: HSlider
	var distance: float
	
	func set_up(p_parent: ControlPanel, p_node: Control, p_initial_distance: float):
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


class ControlLight:
	var parent: ControlPanel
	var node: Control
	var label_angle: Label
	var slider: HSlider
	var angle: float
	
	func set_up(p_parent: ControlPanel, p_node: Control, p_initial_angle: float):
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
		SceneSandbox.instance.light.global_position = parent.light_distance * Vector3(cos(angle_rad), 0, sin(angle_rad))
		label_angle.text = "Light Position (%d°)" % angle
