extends Control

signal toggle_gravity(enabled)

func _ready() -> void:
	hide()

func _on_CheckBox_toggled(button_pressed: bool) -> void:
	emit_signal("toggle_gravity", button_pressed)

func _on_Button_pressed() -> void:
	hide()
