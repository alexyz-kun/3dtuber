class_name SceneMain
extends Node

static var instance: SceneMain

var manager := GlobalManager.new()
var current_scene: Node3D
var current_scene_parent: Node3D

# Base methods

func _ready() -> void:
	if instance == null:
		instance = self
	
	# RenderingServer.set_default_clear_color(Color.GRAY)
	
	current_scene_parent = $CurrentSceneParent
	
	var first_scene: SceneSandbox = load(manager.resource.scene.sandbox).instantiate()
	current_scene_parent.add_child(first_scene)
	current_scene = first_scene
	SceneSandbox.instance = first_scene
	first_scene.set_up()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# For input pressed
			match event.button_index:
				MouseButton.MOUSE_BUTTON_LEFT:
					manager.input.lmb_pressed.emit()
				MouseButton.MOUSE_BUTTON_RIGHT:
					pass
		else:
			# Same as pressed, but for input release
			match event.button_index:
				MouseButton.MOUSE_BUTTON_LEFT:
					manager.input.lmb_released.emit()


# Subclasses

class GlobalManager:
	static var resource := ResourceManager.new()
	static var input := InputManager.new()


class ResourceManager:
	static var scene := SceneResourceManager.new()
	static var prefab := PrefabResourceManager.new()
	static var sound := SoundResourceManager.new()
	static var music := MusicResourceManager.new()
	
	# Subclasses
	
	class SceneResourceManager:
		static var sandbox: String = "res://scenes/scene_sandbox.tscn"
	
	
	class PrefabResourceManager:
		static var placeholder: String
	
	
	class SoundResourceManager:
		static var placeholder: String
	
	
	class MusicResourceManager:
		static var placeholder: String


class InputManager:
	signal lmb_pressed
	signal lmb_released
