extends Area2D


func _on_body_entered(body):
	print(body)
	$Timer.start(0.1)

func _on_timer_timeout():
	$BoxTop.hide()
