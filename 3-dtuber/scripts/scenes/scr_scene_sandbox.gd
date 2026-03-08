class_name SceneSandbox
extends Node3D

enum SandboxState {
	ADJUST_CAMERA_AND_LIGHTING,
	ADJUST_EYES,
}

const CURSOR_Z_DISTANCE: float = 1

static var instance: SceneSandbox

var avatar_subviewport: SubViewport
var camera: Camera3D
var audio_stream_recorder: AudioRecorder
var debug_cursor: MeshInstance3D

# Side menu
var button_adjust_camera_and_lighting: Button
var button_adjust_eyes: Button

# Menu 1 | Adjust camera and lighting
var avatar: Avatar
var avatar_frame: AvatarFrame
var light: OmniLight3D
var control_panel: ControlPanel

# Menu 2 | Adjust eyes
var eye_sphere: MeshInstance3D

var lerp_1 := Lerp_SideMenu_AdjustEyes_AvatarFrame_Animation.new()

var menu_state: SandboxState
var ui_is_hidden: bool

# Base methods

func set_up():
	avatar_subviewport = $Node3D/AvatarSubViewport
	camera = $Node3D/AvatarSubViewport/Camera3D
	audio_stream_recorder = $Node/AudioStreamRecorder
	
	debug_cursor = $Node3D/AvatarSubViewport/Debug/Debug_Cursor
	
	# Side menu
	button_adjust_camera_and_lighting = $Control/SideMenu/MarginContainer/VBoxContainer/Button_Camera_Lighting
	button_adjust_eyes = $Control/SideMenu/MarginContainer/VBoxContainer/Button_Eyes
	
	# Menu 1 | Adjust camera and lighting
	avatar = $Node3D/AvatarSubViewport/Avatar
	avatar_frame = $Control/AvatarFrame
	light = $Node3D/AvatarSubViewport/Light
	control_panel = $Control/ControlPanel
	
	button_adjust_camera_and_lighting.pressed.connect(_on_button_adjust_camera_and_lighting_pressed)
	button_adjust_eyes.pressed.connect(_on_button_adjust_eyes_pressed)
	
	menu_state = SandboxState.ADJUST_CAMERA_AND_LIGHTING
	
	lerp_1.set_up(avatar_frame, avatar_subviewport)
	
	avatar.set_up()
	avatar_frame.set_up()
	control_panel.set_up()


func _process(p_delta: float) -> void:
	var avatar_texture: ViewportTexture = avatar_subviewport.get_texture()
	avatar_frame.image.texture = avatar_texture
	
	if Input.is_action_just_pressed("hotkey_toggle_ui"):
		_toggle_ui()
	
	lerp_1.tick(p_delta)


# Public methods

func get_cursor_world_pos() -> Vector3:
	var viewport: Viewport = get_viewport()
	var screen_size: Vector2 = viewport.get_visible_rect().size
	var cursor_screen_pos: Vector2 = viewport.get_mouse_position()
	
	var frame_center_pos: Vector2 = avatar_frame.get_center()
	var look_vec := Vector2(cursor_screen_pos - frame_center_pos)
	
	var look_vec_t: Vector2 = look_vec
	look_vec_t.x /= screen_size.x
	look_vec_t.y /= screen_size.y
	
	var cursor_world_pos := Vector3(
		lerpf(-0.5, 0.5, 0.5 + look_vec_t.x),
		lerpf(0.5, -0.5, 0.5 + look_vec_t.y),
		CURSOR_Z_DISTANCE)
	
	SceneSandbox.instance.debug_cursor.global_position = cursor_world_pos
	
	return cursor_world_pos


# Private methods

func _toggle_ui():
	ui_is_hidden = !ui_is_hidden
	avatar_frame.toggle_lock(ui_is_hidden)
	control_panel.visible = !ui_is_hidden


# On UI interact

func _on_button_adjust_camera_and_lighting_pressed():
	if menu_state == SandboxState.ADJUST_CAMERA_AND_LIGHTING:
		return
	menu_state = SandboxState.ADJUST_CAMERA_AND_LIGHTING
	
	avatar.movement_state = Avatar.HeadMovementState.FOLLOW_CURSOR
	avatar_frame.is_locked = false
	lerp_1.animate_from_fullscreen()
	control_panel.visible = true


func _on_button_adjust_eyes_pressed():
	if menu_state == SandboxState.ADJUST_EYES:
		return
	menu_state = SandboxState.ADJUST_EYES
	
	# avatar.visible = false
	avatar.movement_state = Avatar.HeadMovementState.STILL
	avatar.mesh_pivot.basis = Quaternion.IDENTITY
	avatar.mesh_pivot.rotate_y(PI)
	avatar_frame.is_locked = true
	lerp_1.animate_to_fullscreen()
	control_panel.visible = false


# Subclasses

class Lerp_SideMenu_AdjustEyes_AvatarFrame_Animation:
	var avatar_frame: AvatarFrame
	var avatar_subviewport: SubViewport
	
	var nonfullscreen_pos: Vector2
	var nonfullscreen_size: Vector2
	var fullscreen_pos: Vector2
	var fullscreen_size: Vector2
	
	var lerp_t: float
	var start_pos: Vector2
	var start_size: Vector2
	var end_pos: Vector2
	var end_size: Vector2
	
	# Base methods
	
	func set_up(p_avatar_frame: AvatarFrame, p_avatar_subviewport: SubViewport):
		avatar_frame = p_avatar_frame
		avatar_subviewport = p_avatar_subviewport
		
		start_pos = avatar_frame.global_position
		end_pos = start_pos
		
		start_size = avatar_frame.size
		end_size = start_size
		
		fullscreen_pos = Vector2.ZERO
		fullscreen_size = SceneMain.instance.get_viewport().get_visible_rect().size
	
	
	func tick(_delta: float):
		_animate()
	
	
	# Public methods
	
	func animate_to_fullscreen():
		nonfullscreen_pos = avatar_frame.global_position
		nonfullscreen_size = avatar_frame.size
		
		lerp_t = 0
		start_pos = nonfullscreen_pos
		start_size = nonfullscreen_size
		end_pos = fullscreen_pos
		end_size = fullscreen_size
	
	
	func animate_from_fullscreen():
		lerp_t = 0
		start_pos = avatar_frame.global_position
		start_size = avatar_frame.size
		end_pos = nonfullscreen_pos
		end_size = nonfullscreen_size
	
	
	# Private methods
	
	func _animate():
		if lerp_t > 0.99:
			return
		lerp_t = lerpf(lerp_t, 1, 0.2)
		
		avatar_frame.global_position = lerp(start_pos, end_pos, lerp_t)
		avatar_frame.size = lerp(start_size, end_size, lerp_t)
		avatar_subviewport.size = avatar_frame.size
		
