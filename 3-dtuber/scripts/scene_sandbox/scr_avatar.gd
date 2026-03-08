class_name Avatar
extends Node3D

enum HeadMovementState {
	STILL,
	FOLLOW_CURSOR,
	FOLLOW_ANIMATION,
}

const WINDOW_WIDTH: int = 1280
const WINDOW_HEIGHT: int = 720

var mesh_pivot: Node3D
var skeleton: Skeleton3D

var movement_state: HeadMovementState

var debug_mesh_torso: MeshInstance3D

# Base methods

func set_up():
	mesh_pivot = $MeshPivot
	skeleton = $ModelAlexyz/Rig/Skeleton3D
	
	movement_state = HeadMovementState.FOLLOW_CURSOR
	
	# Debug
	debug_mesh_torso = $ModelAlexyz/Rig/Skeleton3D/torso


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


# Private methods

var debug_angle_t: float
var debug_angle_x: float
var debug_angle_y: float

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
	
	var test_q := Quaternion.from_euler(Vector3(0, sin(debug_angle_t), 0))
	debug_angle_t += 0.1
	
	# skeleton.set_bone_pose_rotation(bone_index, test_q)


func _follow_cursor():
	if !mesh_pivot:
		return
	
	mesh_pivot.look_at(SceneSandbox.instance.get_cursor_world_pos())
