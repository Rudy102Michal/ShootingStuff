extends Camera

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

var players_container : Spatial
var distance_translation : Vector3 = Vector3(0.0, 10.0, 10.0)

var camera_angle : float = PI / 6.0
var camera_distance

func _ready():
	_set_players_container()


func _physics_process(delta):
	if players_container == null:
		_set_players_container()
		return
	
	var players : Array = players_container.get_children()
	var at_target : Vector3
	var cam_position : Vector3
	
	if players.size() == 1:
		at_target = players[0].global_transform.origin
		cam_position = at_target + distance_translation
	elif players.size() == 2:
		var players_shift : Vector3 = players[0].global_transform.origin - players[1].global_transform.origin
		# Point camera at exactly middle between players
		at_target = players[1].global_transform.origin + players_shift * 0.5
		cam_position = at_target + distance_translation
	
	look_at_from_position(cam_position, at_target, VECTOR_UP)	
			
func _set_players_container():
	players_container = $"../StuffOnScreen/Players"