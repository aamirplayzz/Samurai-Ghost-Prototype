extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var dialogue: CanvasLayer = $DialogueManager
@onready var cinematic: Node3D = $Cinematic
@onready var mobile_ui: Control = $MobileUI
@onready var joystick: Control = $MobileUI/VirtualJoystick
@onready var attack_button: Button = $MobileUI/AttackButton
@onready var skip_button: Button = $MobileUI/SkipCinematicButton

var story_started: bool = false

func _ready() -> void:
	if cinematic:
		cinematic.cinematic_finished.connect(_on_cinematic_finished)
	if dialogue:
		dialogue.dialogue_finished.connect(_on_dialogue_finished)
	if joystick and joystick.has_signal("direction_changed"):
		joystick.direction_changed.connect(_on_joystick_moved)
	if attack_button:
		attack_button.pressed.connect(_on_attack_pressed)
	if skip_button:
		skip_button.pressed.connect(_on_skip_cinematic)
	mobile_ui.visible = true
	await get_tree().create_timer(0.5).timeout
	if cinematic:
		cinematic.play_intro()
	else:
		_on_cinematic_finished()

func _on_cinematic_finished() -> void:
	_start_story_intro()

func _start_story_intro() -> void:
	if story_started:
		return
	story_started = true
	var intro_lines: Array[Dictionary] = [
		{"speaker": "Narrator", "text": "The year is 1274. The Mongol Empire has set its sights on the islands of Japan."},
		{"speaker": "Narrator", "text": "Tsushima has fallen. Only a handful of samurai remain to defend what is left."},
		{"speaker": "Jin", "text": "I am Jin Sakai... the last hope of this island."},
		{"speaker": "Jin", "text": "They call me the Ghost. I will become whatever is necessary to protect my people."},
		{"speaker": "Narrator", "text": "Your journey begins at the old temple. Explore, fight, and uncover the truth."},
		{"speaker": "System", "text": "Use the left joystick to move. Tap Attack to strike."},
	]
	if dialogue:
		dialogue.start_dialogue(intro_lines)

func _on_dialogue_finished() -> void:
	print("Story intro complete. Gameplay starts.")

func _on_joystick_moved(dir: Vector2) -> void:
	if player and player.has_method("set_mobile_move"):
		player.set_mobile_move(dir)

func _on_attack_pressed() -> void:
	if player and player.has_method("set_mobile_attack"):
		player.set_mobile_attack(true)

func _on_skip_cinematic() -> void:
	if cinematic and cinematic.has_method("skip"):
		cinematic.skip()
