extends Camera

var players_container
# Called when the node enters the scene tree for the first time.

func _ready():
	_set_players_container()


func _physics_process(delta):
	if players_container == null:
		_set_players_container()
		return
	
	var players : Array = players_container.get_children()
	
	if players.size() == 1:
		var at_target : Vector3 = players[0].global_transform.origin
		var cam_position : Vector3 = at_target + Vector3(0.0, 10.0, 10.0)
		look_at_from_position(cam_position, at_target, Vector3(0.0, 1.0, 0.0))
	elif players.size() == 2:
		var players_shift : Vector3 = players[0].global_transform.origin - players[1].global_transform.origin
		var distance : float = players_shift.length()
			
			
func _set_players_container():
	players_container = $"../StuffOnScreen/Players"