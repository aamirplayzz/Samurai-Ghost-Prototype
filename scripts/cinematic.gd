extends Node3D

@export var cinematic_camera: Camera3D
@export var player_camera: Camera3D
@export var duration: float = 8.0

@onready var path: Path3D = $CameraPath
@onready var path_follow: PathFollow3D = $CameraPath/PathFollow3D

var is_playing: bool = false
var elapsed: float = 0.0

signal cinematic_finished

func _ready() -> void:
	if cinematic_camera:
		cinematic_camera.current = false
	path_follow.progress_ratio = 0.0

func play_intro() -> void:
	if not cinematic_camera or not path:
		emit_signal("cinematic_finished")
		return
	is_playing = true
	elapsed = 0.0
	path_follow.progress_ratio = 0.0
	cinematic_camera.current = true
	if player_camera:
		player_camera.current = false
	get_tree().call_group("ui", "hide")

func _process(delta: float) -> void:
	if not is_playing:
		return
	elapsed += delta
	path_follow.progress_ratio = clamp(elapsed / duration, 0.0, 1.0)
	if elapsed >= duration:
		_finish()

func _finish() -> void:
	is_playing = false
	if player_camera:
		player_camera.current = true
	if cinematic_camera:
		cinematic_camera.current = false
	get_tree().call_group("ui", "show")
	emit_signal("cinematic_finished")

func skip() -> void:
	if is_playing:
		_finish()
