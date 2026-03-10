class_name UtilMath

#region Angle

static func get_vector_from_angle(dir: float) -> Vector2:
	return Vector2(cos(dir), sin(dir))


static func get_angle_from_vector(dir: Vector2) -> float:
	return dir.angle()

#endregion

#region Rect

static func point_is_inside_rect(
	point: Vector2,
	rect_top_left: Vector2,
	rect_bottom_right: Vector2) -> bool:
	
	return point.x >= rect_top_left.x \
		and point.x <= rect_bottom_right.x \
		and point.y >= rect_top_left.y \
		and point.y <= rect_bottom_right.y

#endregion

#region Lerp

static func delta_lerp(
	a: float,
	b: float,
	rate: float,
	delta: float) -> float:
	
	return b + (a - b) * exp(-rate * delta)


static func delta_lerp_vec2(
	a: Vector2,
	b: Vector2,
	rate: float,
	delta: float) -> Vector2:
	
	return b + (a - b) * exp(-rate * delta)


static func delta_lerp_vec3(
	a: Vector3,
	b: Vector3,
	rate: float,
	delta: float) -> Vector3:
	
	return b + (a - b) * exp(-rate * delta)

#endregion
