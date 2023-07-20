extends Control
class_name Multiplayer_UI

var last_scene_request

@export_category('Multiplayer Join/Host')
@export var multiplayer_menu: Control
@export var host_btn: Button
@export var join_btn: Button

@export_category('Scene Change Request')
@export var scene_request: Control
@export var request_label: Label
@export var replie_yes: Button
@export var replie_no: Button

#To Override in inherited class
func diplay_request(player: Player_Multi, scene_name: String):
	request_label.text = 'player ' + player.name + ' want to go to scene ' + scene_name + ' are you ready ?'
	return

func _ready():
	SceneEventBus.on_change_level_triggered.connect(display_request)
	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)
	replie_yes.pressed.connect(_on_replie_yes_pressed)
	replie_no.pressed.connect(_on_replie_no_pressed)

func _on_host_pressed():
	SceneEventBus.on_ui_host_pressed.emit()
	multiplayer_menu.hide()

func _on_join_pressed():
	SceneEventBus.on_ui_join_pressed.emit()
	multiplayer_menu.hide()

func display_request(player: Player_Multi, scene_name: String):
	diplay_request(player, scene_name)
	last_scene_request = scene_name
	scene_request.show()

func _on_replie_yes_pressed():
	SceneEventBus.on_ui_replie.emit(last_scene_request, true)
	scene_request.hide()

func _on_replie_no_pressed():
	SceneEventBus.send('on_ui_replie_request', [last_scene_request, false])
	scene_request.hide()
