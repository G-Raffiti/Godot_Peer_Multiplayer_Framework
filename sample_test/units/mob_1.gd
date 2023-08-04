extends CharacterBody2D

func _process(delta):
	position += Vector2(1 - 2 * randf(), 1 - 2 * randf()) * 500* delta

func _on_area_2d_body_entered(_body):
	call_deferred('queue_free')
