extends Node2D
class_name Level_Multi

@export var player_spawn_points: Node2D
@export var unit_spawn_points: Node2D
@export var units: Node2D

func change_zone(player_body: Player_Multi, scene_name: String):
	SceneEventBus.on_change_level_triggered.emit(player_body, scene_name)

func place_players(scene_name: String):
	if is_multiplayer_authority():
		for point in player_spawn_points.get_children():
			if point.name == scene_name and 'position' in point:
				SceneEventBus.send_all('on_level_spawn_point', point.position)
				return

func get_spawn_units() -> Array:
	var spawn_points: Array = []
	for point in unit_spawn_points.get_children():
		if 'position' in point:
			var unit_name: String = point.name.substr(0, point.name.find('|'))
			spawn_points.append([point.position, unit_name])
	return spawn_points
