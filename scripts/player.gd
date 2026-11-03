extends CharacterBody3D

## Mobile-only third-person samurai controller
## Only virtual joystick + touch buttons (no WASD)

@export var speed: float = 6.0
@export var sprint_multiplier: float = 1.6
@export var jump_velocity: float = 4.5
@export var rotation_speed: float = 10.0
@export var attack_cooldown: float = 0.6

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var model: Node3D = $Model
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer if has_node("Model/AnimationPlayer") else null

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var can_attack: bool = true
var is_attacking: bool = false
var is_sprinting: bool = false

var mobile_move: Vector2 = Vector2.ZERO
var mobile_attack_pressed: bool = false

signal attack_performed
signal dialogue_requested

func _ready() -> void:
	if spring_arm:
		spring_arm.add_excluded_object(self.get_rid())

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir: Vector2 = mobile_move
	var direction := Vector3.ZERO
	if camera:
		var cam_basis = camera.global_transform.basis
		direction = (cam_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		direction.y = 0
	else:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction.length() > 0.1:
		var target_speed = speed * (sprint_multiplier if is_sprinting else 1.0)
		velocity.x = direction.x * target_speed
		velocity.z = direction.z * target_speed
		var target_rot = atan2(direction.x, direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_rot, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

	if mobile_attack_pressed and can_attack and not is_attacking:
		perform_attack()

func perform_attack() -> void:
	is_attacking = true
	can_attack = false
	emit_signal("attack_performed")
	if animation_player and animation_player.has_animation("attack"):
		animation_player.play("attack")
	else:
		print("Katana slash!")
	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false
	can_attack = true
	mobile_attack_pressed = false

func set_mobile_move(dir: Vector2) -> void:
	mobile_move = dir

func set_mobile_attack(pressed: bool) -> void:
	if pressed:
		mobile_attack_pressed = true

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if event.position.x > get_viewport().get_visible_rect().size.x * 0.5:
			camera_pivot.rotate_y(-event.relative.x * 0.005)
			spring_arm.rotate_x(-event.relative.y * 0.005)
			spring_arm.rotation.x = clamp(spring_arm.rotation.x, -1.2, 0.4)
