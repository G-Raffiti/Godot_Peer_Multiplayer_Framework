extends Area2D

func _on_body_entered(body):
	call_deferred('queue_free')
	if 'score' in body:
		body.score += 1
