extends Node2D
class_name Game_Multi

var peer = ENetMultiplayerPeer.new()
var HOST: int = 1
var PORT: int = 135
var IP_HOST: String = 'localhost'

var player_amount = 0
@export var player_ps :PackedScene

var scene_request = {}
@export var scenes: Array[PackedScene]
var scenes_dict: Dictionary = {}

func _ready():
	SceneEventBus.on_ui_host_pressed.connect(_on_host_game)
	SceneEventBus.on_ui_join_pressed.connect(_on_join_game)
	for scene in scenes:
		var scene_name: String = scene.resource_path
		while scene_name.find('/') >= 0:
			scene_name = scene_name.substr(scene_name.find('/') + 1)
		scene_name = scene_name.trim_suffix('.tscn')
		scenes_dict[scene_name] = scene

func _on_host_game() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	SceneEventBus.add_scene.connect(_add_scene)
	SceneEventBus.on_ui_replie_request.connect(_on_replied_change_scene)
	_add_player(HOST)
	_add_scene('loby')

func _on_join_game() -> void:
	peer.create_client(IP_HOST, PORT)
	multiplayer.multiplayer_peer = peer

func _add_player(id: int) -> void:
	player_amount += 1
	var player = player_ps.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _add_scene(scene_name: String) -> void:
	if not scenes_dict.has(scene_name):
		printerr('The given scene (', scene_name, ') does not exist')
		return
	for child in %Level.get_children():
		child.call_deferred('queue_free')
	var level = scenes_dict[scene_name].instantiate()
	%Level.call_deferred("add_child", level, true)

func _on_replied_change_scene(params: Array) -> void:
	var scene_name = params[0]
	var anser = params[1]
	if anser:
		if not scene_request.has(scene_name):
			scene_request[scene_name] = 0
		scene_request[scene_name] += 1
	if not anser:
		scene_request[scene_name] = 0
	if scene_request[scene_name] == player_amount:
		scene_request.clear()
		SceneEventBus.send('add_scene', scene_name)
