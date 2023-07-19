extends Node

const HOST: int = 1

# Host / Join Game
signal on_ui_host_pressed()
signal on_ui_join_pressed()


# Scene Transition Signals
signal on_change_level_triggered(player: Player_Multi, scene_name: String)
signal on_ui_replie_request(params) #params Array[scene:String, anser:bool]
signal add_scene(scene_name: String)

func send(sig_name: String, params):
	if not sig_name in self:
		printerr(sig_name, ' signal does not exist in the EventBus')
		return
	if multiplayer.get_unique_id() == HOST:
		emit_signal(sig_name, params)
	else:
		rpc('emit_host_signal', sig_name, params)

@rpc("any_peer")
func emit_host_signal(sig_name, params):
	emit_signal(sig_name,params)
