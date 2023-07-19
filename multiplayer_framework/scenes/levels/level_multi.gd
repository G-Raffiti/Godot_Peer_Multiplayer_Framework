extends Node2D
class_name Level_Multi

func change_zone(player_body: Player_Multi, scene_name: String):
	SceneEventBus.on_change_level_triggered.emit(player_body, scene_name)
