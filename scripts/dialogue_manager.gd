extends CanvasLayer

@onready var panel: Panel = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/SpeakerLabel
@onready var text_label: Label = $DialoguePanel/TextLabel
@onready var continue_button: Button = $DialoguePanel/ContinueButton

var dialogue_queue: Array[Dictionary] = []
var current_index: int = 0
var is_active: bool = false

signal dialogue_finished
signal line_spoken(speaker: String, text: String)

func _ready() -> void:
	panel.visible = false
	continue_button.pressed.connect(_on_continue)

func start_dialogue(lines: Array[Dictionary]) -> void:
	dialogue_queue = lines
	current_index = 0
	is_active = true
	panel.visible = true
	_show_current_line()

func _show_current_line() -> void:
	if current_index >= dialogue_queue.size():
		_end_dialogue()
		return
	var line = dialogue_queue[current_index]
	speaker_label.text = line.get("speaker", "???")
	text_label.text = line.get("text", "...")
	emit_signal("line_spoken", speaker_label.text, text_label.text)

func _on_continue() -> void:
	current_index += 1
	_show_current_line()

func _end_dialogue() -> void:
	is_active = false
	panel.visible = false
	emit_signal("dialogue_finished")

func _input(event: InputEvent) -> void:
	if is_active and (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")):
		_on_continue()
