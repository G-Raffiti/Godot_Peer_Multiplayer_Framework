extends CharacterBody2D
class_name Player_Multi

#To Override in inherited class
func _authority_process(_delta):
	velocity = Input.get_vector('ui_left', 'ui_right', 'ui_up', 'ui_down') * 400
	return

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _process(delta):
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		_authority_process(delta)
	move_and_slide()
