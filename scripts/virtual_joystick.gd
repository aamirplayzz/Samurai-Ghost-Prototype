extends Control

@export var joystick_radius: float = 80.0
@export var knob_radius: float = 30.0
@export var deadzone: float = 0.15

var touch_index: int = -1
var center: Vector2
var knob_pos: Vector2
var output: Vector2 = Vector2.ZERO

@onready var base: ColorRect = $Base
@onready var knob: ColorRect = $Knob

signal direction_changed(direction: Vector2)

func _ready() -> void:
	center = size / 2.0
	knob_pos = center
	_update_visuals()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			_update_knob(event.position)
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			knob_pos = center
			output = Vector2.ZERO
			emit_signal("direction_changed", output)
			_update_visuals()
	elif event is InputEventScreenDrag and event.index == touch_index:
		_update_knob(event.position)

func _update_knob(pos: Vector2) -> void:
	var offset = pos - center
	var max_dist = joystick_radius - knob_radius
	if offset.length() > max_dist:
		offset = offset.normalized() * max_dist
	knob_pos = center + offset
	var dir = offset / max_dist
	if dir.length() < deadzone:
		output = Vector2.ZERO
	else:
		output = dir
	emit_signal("direction_changed", output)
	_update_visuals()

func _update_visuals() -> void:
	if base:
		base.position = center - Vector2(joystick_radius, joystick_radius)
		base.size = Vector2(joystick_radius * 2, joystick_radius * 2)
	if knob:
		knob.position = knob_pos - Vector2(knob_radius, knob_radius)
		knob.size = Vector2(knob_radius * 2, knob_radius * 2)

func get_direction() -> Vector2:
	return output
