extends Node2D
class_name Game_Multi
## Game_Multi is the core of this Multiplayer_Framework
##
## Game_Multi is used to link all the part together and manage the level transition [br]
## It contains the ENet Multiplayer Peer and all the lists of every Spawnable objets

var peer = ENetMultiplayerPeer.new()
var HOST: int = 1
var PORT: int = 8080
var IP_HOST: String = 'localhost'

var player_amount = 0

## Player Packed Scene, will be created for each player joining the party
@export var player_ps: PackedScene
@onready var player_spawner: MultiplayerSpawner = $Services/MultiplayerSpawners/PlayerSpawner

var change_level_request = []

## Add here the Levels as PackedScene that will be used in the game
@export var levels_ps: Array[PackedScene]
@onready var level_spawner: MultiplayerSpawner = $Services/MultiplayerSpawners/LevelSpawner
var levels_dict: Dictionary = {}
var current_level_name: String = 'main_menu'
var current_level: Level_Multi = null

## Add here the Units/PNJ as PackedScene that will be used in the game
@export var units_ps: Array[PackedScene]
@onready var unit_spawner: UnitSpawner = $Services/UnitSpawner

## Add here the Objects/Loots as PackedScene that will be used in the game [br]
## (only the Objects/Loots that shoold spawn and be synchronise for all players should be added here)
@export var objects_ps: Array[PackedScene]
@onready var object_spawner: ObjectSpawner = $Services/ObjectSpawner

#To Override in Inherited class
## Method Called just before the player node is added as a child of the '%Players'
func virtual_add_player(_player: Node, _id: int) -> void:
	return

## Method Called at the end of a Level Transition
func virtual_level_added(_level_name: String) -> void:
	return

func _init_spawners(level_name: String):
	virtual_init_unit_spawner(level_name)
	virtual_init_object_spawner(level_name)

## Method Called et every Level Transition [br]
## If you want to change the list of units that can be spawned for this level [br]
## (example: randomize, etc...) you should do that here. 
@rpc('authority', 'call_local')
func virtual_init_unit_spawner(_level_name):
	unit_spawner.units = units_ps
	unit_spawner.fill_spawner()

## Method Called et every Level Transition [br]
## If you want to change the list of objects/loots that can be spawned for this level [br]
## (example: randomize, etc...) you should do that here. 
@rpc('authority', 'call_local')
func virtual_init_object_spawner(_level_name):
	object_spawner.objects_ps = objects_ps
	unit_spawner.fill_spawner()

## Godot Ready Function (Called only once on this framework)
func _ready():
	SceneEventBus.on_ui_host_pressed.connect(_on_host_game) ## Listen for the Host Button
	SceneEventBus.on_ui_join_pressed.connect(_on_join_game) ## Listen for the Join Button
	SceneEventBus.on_game_level_init.connect(_init_spawners)
	manage_levels_ps_resources() ## Add the Levels to the [MultiplayerSpawner]
	player_spawner.add_spawnable_scene(player_ps.resource_path) ## Add the Player's [PackedScene] to the [MultiplayerSpawner]

## Fill the Dictionnary 'levels_dict' with the Levels Names as [string] and Levels [PackedScene] [br]
## Also add the [PackedScene] to the [MultiplayerSpawner].
func manage_levels_ps_resources():
	for level_ps in levels_ps:
		var level_name: String = level_ps.resource_path
		level_spawner.add_spawnable_scene(level_name)
		while level_name.find('/') >= 0:
			level_name = level_name.substr(level_name.find('/') + 1)
		level_name = level_name.trim_suffix('.tscn')
		levels_dict[level_name] = level_ps

## Create the Player for the Host and connect the Level's Transition to this peer [br]
## Create also the first Level called 'lobby'
func _on_host_game() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	SceneEventBus.add_level.connect(_add_level)
	SceneEventBus.on_ui_replie_request.connect(_on_replied_change_level)
	_add_player(HOST)
	_add_level('lobby')

## Method Called on Join Button Pressed, a PlayerScene will be instantiated for the new Player
func _on_join_game() -> void:
	peer.create_client(IP_HOST, PORT)
	multiplayer.multiplayer_peer = peer

## Add a player_scene on the Host side and name it after the Player's ID [br]
## Player Authority is managed in the [Player_Multi] script
func _add_player(id: int) -> void:
	player_amount += 1
	var player = player_ps.instantiate()
	if current_level != null:
		for point in current_level.player_spawn_points.get_children():
			if point.name == 'main_menu' and 'position' in point:
				player.position = point.position
	player.name = str(id)
	virtual_add_player(player, id)
	%Players.call_deferred("add_child", player)
	await get_tree().process_frame
	

## Method Called to Transition to an other Level
func _add_level(level_name: String) -> void:
	if not levels_dict.has(level_name):
		printerr('The given level (', level_name, ') does not exist')
		return
	
	SceneEventBus.send_all('disable_players')
	if current_level != null:
		SceneEventBus.send('on_game_quit_level', current_level)
	await get_tree().process_frame
	
	for child in %Level.get_children():
		child.call_deferred('queue_free')
	await get_tree().process_frame
	
	current_level = levels_dict[level_name].instantiate()
	%Level.call_deferred("add_child", current_level, true)
	await get_tree().process_frame
	
	SceneEventBus.send_all('on_game_level_init', level_name)
	
	SceneEventBus.send('on_game_level_spawned', current_level)
	current_level.call_deferred("place_players", current_level_name)
	await get_tree().process_frame
	
	call_deferred("virtual_level_added", level_name)
	await get_tree().process_frame
	current_level_name = level_name

## Method Called when each player choose to agree to the Level Transition [br]
## by default all players should agree to mode to the next level
func _on_replied_change_level(params: Array) -> void:
	var level_name = params[0]
	var answer = params[1]
	var player_name = params[2]
	
	if change_level_request.is_empty() or change_level_request[0] != level_name:
		change_level_request = [level_name, 0, 0]
	if change_level_request.has(player_name):
		return
	change_level_request.append(player_name)
	change_level_request[1] += 1
	if answer:
		change_level_request[2] += 1
	if not answer:
		change_level_request[0] = 'no'
	if change_level_request[1] == player_amount:
		if change_level_request[2] == player_amount:
			SceneEventBus.send('add_level', level_name)
		change_level_request.clear()
