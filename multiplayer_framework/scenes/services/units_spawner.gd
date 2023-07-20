extends Node

@export var unit_spawner: MultiplayerSpawner
@export var units: Array[PackedScene]
var units_dict: Dictionary
var units_in_levels: Dictionary

func fill_unit_dict():
	for unit in units:
		var unit_name: String = unit.resource_path
		while unit_name.find('/') >= 0:
			unit_name = unit_name.substr(unit_name.find('/') + 1)
		unit_name = unit_name.trim_suffix('.tscn')
		units_dict[unit_name] = unit

func fill_spawner():
	for unit in units:
		var unit_name: String = unit.resource_path
		unit_spawner.add_spawnable_scene(unit_name)

func _ready():
	fill_unit_dict()
	fill_spawner()
	SceneEventBus.on_game_quit_level.connect(record_level)
	SceneEventBus.on_game_level_spawned.connect(spawn_units_in_level)
	SceneEventBus.on_game_level_init.connect(init_spawner_level)

func init_spawner_level(level_name: String):
	unit_spawner.spawn_path = '../../../Level/' + level_name + '/Units'

func record_level(level: Level_Multi):
	units_in_levels[level.name] = []
	for unit in level.units.get_children():
		var unit_name: String = unit.name.substr(0, unit.name.find('|'))
		if 'position' in unit and units_dict.has(unit_name):
			units_in_levels[level.name].append([unit.global_position, unit_name])

func spawn_units_in_level(level: Level_Multi):
	if not units_in_levels.has(level.name):
		units_in_levels[level.name] = level.get_spawn_units()
	
	var unit_number: int = 0
	for pair in units_in_levels[level.name]:
		var unit: Node2D
		if units_dict.has(pair[1]):
			unit = units_dict[pair[1]].instantiate()
			unit.name = pair[1] + '|' + str(unit_number)
		elif pair[1] == 'random':
			unit = units[0].instantiate()
			unit.name = unit.name + '|' + str(unit_number)
		else:
			continue
		level.units.call_deferred('add_child', unit, true)
		unit.set_deferred('global_position', pair[0])
