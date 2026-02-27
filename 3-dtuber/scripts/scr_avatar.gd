class_name Avatar
extends Node

var mesh_pivot: Node3D

# Base methods

func set_up():
	mesh_pivot = $MeshPivot


func _process(delta: float) -> void:
	_follow_cursor()


# Private methods

func _follow_cursor():
	if !mesh_pivot:
		return
	
	var cursor_screen_pos: Vector2 = SceneMain.main_viewport.get_mouse_position()
	var ray_from: Vector3 = SceneMain.camera.project_ray_origin(cursor_screen_pos)
	var ray_to: Vector3 = ray_from + 0.5 * SceneMain.camera.project_ray_normal(cursor_screen_pos)
	
	mesh_pivot.look_at(ray_to)
	mesh_pivot.rotate(Vector3.UP, 0.5 * PI)
