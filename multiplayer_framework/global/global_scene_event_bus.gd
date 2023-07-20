extends Node

const HOST: int = 1

# Host / Join Game
signal on_ui_host_pressed()
signal on_ui_join_pressed()

# Scene Transition Signals
signal on_change_level_triggered(player: Player_Multi, scene_name: String)
signal on_ui_replie_request(params: Array) #params Array[scene:String, answer:bool, player_name:String]
signal add_scene(scene_name: String)
signal disable_players(empty_param)
signal on_level_spawn_point(spawn_point: Vector2)
signal on_game_quit_level(current_level: Level_Multi)
signal on_game_level_init(level_name: String)
signal on_game_level_spawned(current_level: Level_Multi)

func send_clients(sig_name: String, params = null):
	if not sig_name in self:
		printerr(sig_name, ' signal does not exist in the EventBus')
		return
	for peer in multiplayer.get_peers():
		rpc_id(peer, 'emit_local_signal', sig_name, params)

func send_all(sig_name: String, params = null):
	if not sig_name in self:
		printerr(sig_name, ' signal does not exist in the EventBus')
		return
	for peer in multiplayer.get_peers():
		rpc_id(peer, 'emit_local_signal', sig_name, params)
	rpc('emit_local_signal', sig_name, params)

func send(sig_name: String, params = null):
	if not sig_name in self:
		printerr(sig_name, ' signal does not exist in the EventBus')
		return
	if multiplayer.get_unique_id() == HOST:
		emit_signal(sig_name, params)
	else:
		rpc('emit_host_signal', sig_name, params)

@rpc("any_peer", "call_local")
func emit_local_signal(sig_name, params):
	print('from: ', multiplayer.get_remote_sender_id(), ' to: ', multiplayer.get_unique_id())
	emit_signal(sig_name, params)

@rpc("any_peer")
func emit_host_signal(sig_name, params):
	emit_signal(sig_name,params)
