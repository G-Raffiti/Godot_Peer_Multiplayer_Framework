extends Node2D
class_name Game_Multi

var peer = ENetMultiplayerPeer.new()
var HOST: int = 1
var PORT: int = 8080
var IP_HOST: String = 'localhost'

var player_amount = 0
@export var player_ps: PackedScene
@onready var player_spawner: MultiplayerSpawner = $Services/MultiplayerSpawners/PlayerSpawner

var scene_request = []

@export var scenes: Array[PackedScene]
@onready var level_spawner: MultiplayerSpawner = $Services/MultiplayerSpawners/LevelSpawner
var scenes_dict: Dictionary = {}
var current_scene: String = 'main_menu'
var current_level: Level_Multi = null

#To Override in Inherited class
func virtual_add_player(_player: Node, _id: int) -> void:
	return

func virtual_add_scene(_scene_name: String) -> void:
	return

func virtual_scene_added(scene_name: String) -> void:
	current_scene = scene_name

func _ready():
	SceneEventBus.on_ui_host_pressed.connect(_on_host_game)
	SceneEventBus.on_ui_join_pressed.connect(_on_join_game)
	for scene in scenes:
		var scene_name: String = scene.resource_path
		level_spawner.add_spawnable_scene(scene_name)
		while scene_name.find('/') >= 0:
			scene_name = scene_name.substr(scene_name.find('/') + 1)
		scene_name = scene_name.trim_suffix('.tscn')
		scenes_dict[scene_name] = scene
	player_spawner.add_spawnable_scene(player_ps.resource_path)

# Signal Response Functions
func _on_host_game() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	SceneEventBus.add_scene.connect(_add_scene)
	SceneEventBus.on_ui_replie_request.connect(_on_replied_change_scene)
	_add_player(HOST)
	_add_scene('lobby')

func _on_join_game() -> void:
	peer.create_client(IP_HOST, PORT)
	multiplayer.multiplayer_peer = peer

func _add_player(id: int) -> void:
	player_amount += 1
	var player = player_ps.instantiate()
	player.name = str(id)
	virtual_add_player(player, id)
	%Players.call_deferred("add_child", player)

func _add_scene(scene_name: String) -> void:
	if not scenes_dict.has(scene_name):
		printerr('The given scene (', scene_name, ') does not exist')
		return
	
	virtual_add_scene(scene_name)
	SceneEventBus.send_all('disable_players')
	if current_level != null:
		SceneEventBus.send('on_game_quit_level', current_level)
	await get_tree().process_frame
	
	for child in %Level.get_children():
		child.call_deferred('queue_free')
	await get_tree().process_frame
	
	current_level = scenes_dict[scene_name].instantiate()
	%Level.call_deferred("add_child", current_level, true)
	await get_tree().process_frame
	
	SceneEventBus.send_all('on_game_level_init', scene_name)
	
	SceneEventBus.send('on_game_level_spawned', current_level)
	current_level.call_deferred("place_players", current_scene)
	await get_tree().process_frame
	
	call_deferred("virtual_scene_added", scene_name)
	await get_tree().process_frame

func _on_replied_change_scene(params: Array) -> void:
	var scene_name = params[0]
	var answer = params[1]
	var player_name = params[2]
	
	if scene_request.is_empty() or scene_request[0] != scene_name:
		scene_request = [scene_name, 0, 0]
	if scene_request.has(player_name):
		return
	scene_request.append(player_name)
	scene_request[1] += 1
	if answer:
		scene_request[2] += 1
	if not answer:
		scene_request[0] = 'no'
	if scene_request[1] == player_amount:
		if scene_request[2] == player_amount:
			SceneEventBus.send('add_scene', scene_name)
		scene_request.clear()
