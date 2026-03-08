class_name AvatarEye
extends Node3D

var mesh_eyeball: MeshInstance3D
var mesh_pupil: MeshInstance3D

var radius: float

# Base methods

func _ready() -> void:
	mesh_eyeball = $EyeballMesh
	mesh_pupil = $PupilMesh
	radius = 0.5


func _process(_delta: float) -> void:
	_update_pupil_pos()


# Private methods

func _update_pupil_pos():
	var vec_from_origin_to_cursor: Vector3 = SceneSandbox.instance.get_cursor_world_pos() - global_position
	var vec_dir_to_cursor: Vector3 = vec_from_origin_to_cursor.normalized()
	mesh_pupil.position = radius * vec_dir_to_cursor
