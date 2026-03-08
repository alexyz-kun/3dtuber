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


func _process(_delta: float) -> void:
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
	
	_animate_mouth()


# Private methods

const Q_MOUTH_CLOSED := Quaternion(Vector3.RIGHT, 1.75)
const Q_MOUTH_OPEN := Quaternion(Vector3.RIGHT, 1.97)
var mouth_is_open: bool

func _toggle_mouth(p_is_open: bool):
	mouth_is_open = p_is_open


func _animate_mouth():
	var bone_jaw_lower_index: int = skeleton.find_bone("bone_jaw_lower")
	var target_jaw_rotation: Quaternion = Q_MOUTH_OPEN if mouth_is_open else Q_MOUTH_CLOSED
	
	var jaw_rotation: Quaternion = skeleton.get_bone_pose_rotation(bone_jaw_lower_index)
	jaw_rotation = jaw_rotation.slerp(target_jaw_rotation, 0.5)
	skeleton.set_bone_pose_rotation(bone_jaw_lower_index, jaw_rotation)


func _head_bone_follow_cursor():
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
