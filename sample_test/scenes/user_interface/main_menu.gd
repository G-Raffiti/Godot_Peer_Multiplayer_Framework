extends Control

@export_category('Multiplayer Join/Host')
@export var multiplayer_menu: Control
@export var host_btn: Button
@export var join_btn: Button

func _ready():
	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)

func _on_host_pressed():
	SceneEventBus.on_ui_host_pressed.emit()
	multiplayer_menu.hide()

func _on_join_pressed():
	SceneEventBus.on_ui_join_pressed.emit()
	multiplayer_menu.hide()

