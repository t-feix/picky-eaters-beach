extends Control

signal closed

func _ready() -> void:
	%TutorialButton.pressed.connect(_on_close)

func _on_close() -> void:
	closed.emit()
