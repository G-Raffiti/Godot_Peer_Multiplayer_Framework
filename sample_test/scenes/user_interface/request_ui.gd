extends Control

var last_scene_request

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
	replie_yes.pressed.connect(_on_replie_yes_pressed)
	replie_no.pressed.connect(_on_replie_no_pressed)


func display_request(player: Player_Multi, scene_name: String):
	diplay_request(player, scene_name)
	last_scene_request = scene_name
	scene_request.show()

func _on_replie_yes_pressed():
	SceneEventBus.send('on_ui_replie_request', [last_scene_request, true, 'name' + str(multiplayer.get_unique_id())])
	scene_request.hide()

func _on_replie_no_pressed():
	SceneEventBus.send('on_ui_replie_request', [last_scene_request, false, 'name' + str(multiplayer.get_unique_id())])
	scene_request.hide()
