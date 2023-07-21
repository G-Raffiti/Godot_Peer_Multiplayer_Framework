extends Area2D

func _on_body_entered(body):
	if 'pick_up' in body:
		body.pick_up(self)
		call_deferred('queue_free')
