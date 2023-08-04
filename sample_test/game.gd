extends Game_Multi

func _on_host_game() -> void:
	super._on_host_game()
	$UI/Label.text = 'HOST'
	
func _on_join_game() -> void:
	super._on_join_game()
	$UI/Label.text = 'CLIENT'

func virtual_add_player(_player: Node, _id: int) -> void:
	return

func virtual_level_added(scene_name: String) -> void:
	current_level_name = scene_name
