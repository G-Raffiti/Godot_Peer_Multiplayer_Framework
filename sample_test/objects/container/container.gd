extends Area2D

var player: Player_Multi
@export var loot_ps: PackedScene
@export var spawn_pos: Marker2D

func _on_body_entered(body):
	$Timer.start(0.2)
	player = body

func _on_body_exited(body):
	if player == body:
		$Timer.stop()

func _on_timer_timeout():
	SceneEventBus.on_loot_spawn.emit(loot_ps, spawn_pos.global_position, true)
