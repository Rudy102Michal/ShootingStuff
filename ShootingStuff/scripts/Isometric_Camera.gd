extends Camera

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const edge_border : float = 15.0

var players_container : Spatial
var distance_translation : Vector3 = Vector3(0.0, 10.0, 10.0)

var camera_angle : float = PI / 6.0
var camera_distance

#var fov_change = 0.0

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
		var distances = []
		distances.append(players[0].global_transform.origin - global_transform.origin)
		distances.append(players[1].global_transform.origin - global_transform.origin)
		var min_dist = min(distances[0].length(), distances[1].length())
		distances[0] = distances[0].normalized() * min_dist
		distances[1] = distances[1].normalized() * min_dist
		var projected_player1_pos : Vector2 = unproject_position(global_transform.origin + distances[0])
		var projected_player2_pos : Vector2 = unproject_position(global_transform.origin + distances[1])
		#var distance = min((players[0].global_transform.origin - global_transform.origin).length(), (players[1].global_transform.origin - global_transform.origin).length())
		#print(distance)
		var fov_change : float = atan((abs(projected_player1_pos.y - projected_player2_pos.y) + edge_border) / (2 * global_transform.origin.distance_to((distances[0] + distances[1]) * 0.5)));
		#fov_change = max(fov_change, 
		fov = min(max(70, rad2deg(fov_change)), 90)
		print(fov)
		#print(max(70, rad2deg(fov_change)))
	
	look_at_from_position(cam_position, at_target, VECTOR_UP)	
			
func _get_player_dependant_fov(player_origin : Vector3) -> float:
	var ret : float = 0.0
	var projected_pos = unproject_position(player_origin)
	#ret = max(atan(a
	return ret
			
func _set_players_container() -> void:
	players_container = $"../StuffOnScreen/Players"