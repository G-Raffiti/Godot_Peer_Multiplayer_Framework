extends CharacterBody2D
class_name Player_Multi

#To Override in inherited class
func virtual_process(_delta):
	velocity = Input.get_vector('ui_left', 'ui_right', 'ui_up', 'ui_down') * 400
	return

func virtual_input(_event):
	return

func _ready():
	SceneEventBus.on_level_spawn_point.connect(_move_to)
	SceneEventBus.disable_players.connect(_disable_collisions)

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _process(delta):
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		virtual_process(delta)
	move_and_slide()

func _input(event):
	if multiplayer.has_multiplayer_peer() and is_multiplayer_authority():
		virtual_input(event)

func _disable_collisions(_param):
	$Collision.set_deferred("disabled", true)

func _move_to(pos: Vector2):
	global_position = pos
	$Collision.set_deferred("disabled", false)
