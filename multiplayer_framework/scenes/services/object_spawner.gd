extends Node
class_name ObjectSpawner

## Dependency -> used to set the [MultiplayerSpawner.spawn_path] on Level Transition
@export var object_spawner: MultiplayerSpawner
## this is where the non_shared objects are instantiate
@export var objects: Node2D
var objects_ps: Array[PackedScene]
var objects_dict: Dictionary
var objects_in_levels: Dictionary

var object_number: int = 0

func fill_object_dict():
	for object in objects_ps:
		objects_dict[get_resource_name(object)] = object

func get_resource_name(packed_scene: PackedScene) -> String:
	var object_name: String = packed_scene.resource_path
	while object_name.find('/') >= 0:
		object_name = object_name.substr(object_name.find('/') + 1)
	object_name = object_name.trim_suffix('.tscn')
	return object_name

func fill_spawner():
	for object in objects_ps:
		var object_name: String = object.resource_path
		object_spawner.add_spawnable_scene(object_name)

func _ready():
	fill_object_dict()
	fill_spawner()
	SceneEventBus.on_game_quit_level.connect(record_level)
	SceneEventBus.on_game_level_spawned.connect(spawn_objects_in_level)
	SceneEventBus.on_game_level_init.connect(init_spawner_level)
	SceneEventBus.on_loot_spawn.connect(_spawn_object)

func init_spawner_level(level_name: String):
	object_spawner.spawn_path = '../../../Level/' + level_name + '/Objects'

func record_level(level: Level_Multi):
	objects_in_levels[level.name] = []
	for object in level.objects.get_children():
		var object_name: String = object.name.substr(0, object.name.find('|'))
		if 'position' in object and objects_dict.has(object_name):
			objects_in_levels[level.name].append([object.global_position, object_name])

func spawn_objects_in_level(level: Level_Multi):
	if not objects_in_levels.has(level.name):
		objects_in_levels[level.name] = level.get_spawn_objects()
	
	object_number = 0
	for pair in objects_in_levels[level.name]:
		var object: Node2D
		if objects_dict.has(pair[1]):
			object = objects_dict[pair[1]].instantiate()
			object.name = pair[1] + '|' + str(object_number)
		elif pair[1] == 'random':
			object = objects_ps[0].instantiate()
			object.name = object.name + '|' + str(object_number)
		else:
			continue
		level.objects.call_deferred('add_child', object, true)
		object.set_deferred('global_position', pair[0])

func _spawn_object(loot_ps: PackedScene, spawn_pos: Vector2, for_every_one: bool):
	# spawn the object on the host/server and show it for every one, the object must have a [MultiplayerSynchronizer]
	if for_every_one and is_multiplayer_authority():
		if not objects_ps.has(loot_ps):
			# add to the Multiplayer Spawner
			var object_name: String = loot_ps.resource_path
			object_spawner.add_spawnable_scene(object_name)
		var object_name: String = get_resource_name(loot_ps)
		var object: Node2D = loot_ps.instantiate()
		object.name = object_name + '|' + str(object_number)
		get_node(object_spawner.spawn_path).call_deferred('add_child', object, true)
		object.set_deferred('global_position', spawn_pos)
	
	elif not for_every_one:
		var object_name: String = get_resource_name(loot_ps)
		var object: Node2D = loot_ps.instantiate()
		object.name = object_name + '|' + str(object_number)
		objects.call_deferred('add_child', object, true)
		object.set_deferred('global_position', spawn_pos)
