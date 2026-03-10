class_name Avatar
extends Node3D

enum HeadMovementState {
	STILL,
	FOLLOW_CURSOR,
	FOLLOW_ANIMATION,
}

const WINDOW_WIDTH: int = 1280
const WINDOW_HEIGHT: int = 720

var skeleton: Skeleton3D
var movement_state: HeadMovementState

# Base methods

func set_up():
	skeleton = $ModelAlexyz/Rig/Skeleton3D
	
	movement_state = HeadMovementState.FOLLOW_CURSOR
	
	SceneMain.instance.manager.input.lmb_pressed.connect(_toggle_mouth.bind(true))
	SceneMain.instance.manager.input.lmb_released.connect(_toggle_mouth.bind(false))


func _process(p_delta: float) -> void:
	match movement_state:
		HeadMovementState.STILL:
			pass
		HeadMovementState.FOLLOW_CURSOR:
			_head_bone_follow_cursor()
			# _follow_cursor()
		HeadMovementState.FOLLOW_ANIMATION:
			pass
		_:
			pass
	
	_animate_mouth(p_delta)


# Private methods

const AUDIO_INPUT_MIN_VALUE: float = -45
const AUDIO_INPUT_MAX_VALUE: float = -40
const MOUTH_JAW_ROTATION_X_CLOSED: float = 1.75
const MOUTH_JAW_ROTATION_X_OPEN: float = 1.97
var mouth_is_open: bool
var target_mouth_animation_t: float
var mouth_animation_t: float

func _toggle_mouth(p_is_open: bool):
	mouth_is_open = p_is_open
	#target_mouth_animation_t = 1.0 if p_is_open else 0.0


func _animate_mouth(p_delta: float):
	var audio_volume: float = SceneSandbox.instance.audio_stream_recorder.get_audio_volume()
	if audio_volume < AUDIO_INPUT_MIN_VALUE:
		target_mouth_animation_t = 0.0
	elif audio_volume > AUDIO_INPUT_MAX_VALUE:
		target_mouth_animation_t = 1.0
	else:
		target_mouth_animation_t = inverse_lerp(AUDIO_INPUT_MIN_VALUE, AUDIO_INPUT_MAX_VALUE, audio_volume)
	
	# Debug log
	SceneSandbox.instance.debug_plotter.add_point(audio_volume)
	
	mouth_animation_t = UtilMath.delta_lerp(mouth_animation_t, target_mouth_animation_t, 16, p_delta)
	
	var bone_jaw_lower_index: int = skeleton.find_bone("bone_jaw_lower")
	var target_jaw_rotation_x: float = lerpf(MOUTH_JAW_ROTATION_X_CLOSED, MOUTH_JAW_ROTATION_X_OPEN, mouth_animation_t)
	var target_jaw_rotation := Quaternion(Vector3.RIGHT, target_jaw_rotation_x)
	
	skeleton.set_bone_pose_rotation(bone_jaw_lower_index, target_jaw_rotation)


func _head_bone_follow_cursor():
	# This should be the distance
	# from the base of your neck bone
	# to the avatar's eyes
	const BONE_ORIGIN_TO_TIP_LENGTH: float = 0.5
	
	var bone_root_index: int = skeleton.find_bone("bone_root")
	var rotate_q := Quaternion.from_euler(Vector3(0, -0.22, 0))
	skeleton.set_bone_pose_rotation(bone_root_index, rotate_q)
	
	var bone_index: int = skeleton.find_bone("bone_neck")
	var bone_pose: Transform3D = skeleton.get_bone_global_pose(bone_index)
	var bone_pos: Vector3 = bone_pose.origin - BONE_ORIGIN_TO_TIP_LENGTH * Vector3.UP
	
	var target_dir: Vector3 = (SceneSandbox.instance.get_cursor_world_pos() - bone_pos).normalized()
	var look_q := Quaternion(Vector3.BACK, target_dir)
	
	bone_pose.basis = Basis(look_q)
	
	skeleton.set_bone_global_pose_override(bone_index, bone_pose, 1.0, true)
