extends Player_Multi

var points: int = 0:
	get:
		return points
	set(value):
		points = value
		SceneEventBus.send_all('on_points_changed', points)

#To Override in inherited class
func virtual_process(_delta):
	velocity = Input.get_vector('ui_left', 'ui_right', 'ui_up', 'ui_down') * 400
	$Node2D.look_at(get_global_mouse_position())
	return

func virtual_input(event):
	if Input.is_action_pressed('ui_accept'):
		self.points += 1

func _ready():
	super._ready()
	$name.text = name
	self.points = points
	SceneEventBus.on_points_changed.connect(_on_on_points_changed)

func pick_up(_collectible: Area2D):
	self.points += 1

func _on_on_points_changed(point_amount):
	print('points')
	if is_multiplayer_authority():
		rpc('update_points_label', point_amount)

@rpc
func update_points_label(point_amount):
	$points.text = str(point_amount) + ' pt'
