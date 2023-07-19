MULTI PLAYER FRAMEWORK

1) In Project/Settings -> Autoload:
	Add			'res://multiplayer_framework/global/global_scene_event_bus.gd'
	NodeName:	'SceneEventBus'

2) Create a new <Root_Scene>:
	create an InheritedScene <Root_Scene> that inherit from:
	'res://multiplayer_framework/scenes/game/game_multiplayer.tscn'

3) Create a <Player_Scene>:
	create an InheritedScene <Player_Scene> that inherit from:
	'res://multiplayer_framework/scenes/player/player_multi.tscn'
	in the <Root_Scene> fill the exported var "Player Ps" with <Player_Scene>

4) Create a new <Level_Scene>:
	create an InheritedScene <Level_Scene> that inherit from:
	'res://multiplayer_framework/scenes/levels/level_multi.tscn'
	in the <Root_Scene> add <Level_Scene> to the "Scenes" exported Array[PackedScene]

you should create your own scripts that expand respectively Game_Multi, Player_Multi and Level_Multi
you can also create your ui expanding on the resources available or by using the Signals present in the global_scene_event_bus.gd

have a Nice Time !
