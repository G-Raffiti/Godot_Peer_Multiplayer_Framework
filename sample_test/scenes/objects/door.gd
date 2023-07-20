extends Area2D

@export var destination: String
var player

func _on_body_entered(body):
	$Timer.start(0.2)
	player = body

func _on_body_exited(body):
	if player == body:
		$Timer.stop()

func _on_timer_timeout():
	SceneEventBus.on_change_level_triggered.emit(player, destination)

