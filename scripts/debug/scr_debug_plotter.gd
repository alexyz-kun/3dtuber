class_name DebugPlotter
extends Control

const MIN_VALUE: float = -45
const MAX_VALUE: float = -30
const DATAPOINT_LIFESPAN: int = 200

var plot_renderer: UtilRender
var list_points: Array[DataPoint]

# Base methods

func set_up():
	plot_renderer = $PlotRenderer
	plot_renderer.set_up(self, "draw_overlay")


func _process(_delta: float) -> void:
	queue_redraw()


func draw_overlay(p_control: Control) -> void:
	var tick_value: float = -100
	while tick_value < 0:
		var font: Font = load("res://fonts/fnt_roboto_regular.ttf")
		
		var t: float = inverse_lerp(MIN_VALUE, MAX_VALUE, tick_value)
		var pos_y: float = lerpf(size.y, 0, t)
		
		p_control.draw_line(
			Vector2(0, pos_y),
			Vector2(size.x, pos_y),
			Color.BLACK,
			2)
		p_control.draw_string(
			font,
			Vector2(0, pos_y - 4),
			"%.2f" % tick_value,
			HORIZONTAL_ALIGNMENT_RIGHT,
			-1,
			16,
			Color.BLACK)
		
		tick_value += 5
	
	for point in list_points:
		var t: float = inverse_lerp(MIN_VALUE, MAX_VALUE, point.value)
		var pos_x: float = 2 * DATAPOINT_LIFESPAN - 2 * point.lifespan
		var pos_y: float = lerpf(size.y, 0, t)
		
		var lifespan_t: float = point.lifespan / float(DATAPOINT_LIFESPAN)
		var color: Color = lerp(Color.ORANGE, Color.GREEN, lifespan_t)
		color.a = lerpf(0, 1, lifespan_t)
		p_control.draw_circle(Vector2(pos_x, pos_y), 3.0, color)


# Public methods

func add_point(p_value: float):
	var new_point := DataPoint.new()
	new_point.value = p_value
	
	for point in list_points:
		point.lifespan -= 1
		
		if point.lifespan <= 0:
			var index: int = list_points.find(point)
			list_points.remove_at(index)
	
	list_points.append(new_point)


# Subclasses

class DataPoint:
	var value: float
	var lifespan: int = DATAPOINT_LIFESPAN
