extends Camera

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const edge_border : float = 20.0

var players_container : Spatial
var distance_translation : Vector3

var camera_angle : float = PI / 6.0
var fov_tangent : float
var camera_distance : float = 1.0

var at_target : Vector3
var cam_position : Vector3

#var fov_change = 0.0

func _ready():
	_set_players_container()
	fov_tangent = 2.0 * tan(deg2rad(fov / 2.0))
	distance_translation = Vector3(0.0, 1.0, 1.0)
	distance_translation = distance_translation.normalized()
#	var players : Array = players_container.get_children()
#	var players_shift : Vector3 = players[0].global_transform.origin - players[1].global_transform.origin
#	# Point camera at exactly middle between players
#	at_target = players[1].global_transform.origin + players_shift * 0.5
#	cam_position = at_target + distance_translation



func _physics_process(delta):
	if players_container == null:
		_set_players_container()
		return
	
	var players : Array = players_container.get_children()
	
			
	if players.size() == 1:
		at_target = players[0].global_transform.origin
		cam_position = at_target + distance_translation * 10 * sqrt(2.0)
	elif players.size() == 2:
		var players_shift : Vector3 = players[0].global_transform.origin - players[1].global_transform.origin
		# Point camera at exactly middle between players
		at_target = players[1].global_transform.origin + players_shift * 0.5
		
		var local_positions : Array = []
		local_positions.append(to_local(players[0].global_transform.origin))
		local_positions.append(to_local(players[1].global_transform.origin))
		
		if local_positions[0].length() > local_positions[1].length():
			var tmp = local_positions[0]
			local_positions[0] = local_positions[1]
			local_positions[1] = tmp
		var plane_normal : Vector3 = Vector3(0.0, 0.0, -1.0)
		var plane_origin : Vector3 = local_positions[0].project(plane_normal)
		
		local_positions[0] = local_positions[0].normalized() * _calc_plane_x_ray_hit(plane_normal, plane_origin, local_positions[0].normalized(), Vector3.ZERO)
		local_positions[0] = local_positions[1].normalized() * _calc_plane_x_ray_hit(plane_normal, plane_origin, local_positions[1].normalized(), Vector3.ZERO)
		
		var height_diff : float = abs(local_positions[0].y - local_positions[1].y)
		var width_diff : float = abs(local_positions[0].x - local_positions[1].x)
		
		var d : float = height_diff / fov_tangent
		d = max(d, width_diff / fov_tangent)
		d = max(d, 10 * sqrt(2))
		
		cam_position = at_target + distance_translation.normalized() * d
		
#		var positions = []
#		positions.append(players[0].global_transform.origin - global_transform.origin)
#		positions.append(players[1].global_transform.origin - global_transform.origin)
#		var min_dist : Vector3 = positions[0] if positions[0].length() < positions[1].length() else positions[1]
#		plane_normal = -global_transform.basis.z
#		var plane_distance : float = min_dist.project(plane_normal).length()
#		positions[0] = positions[0].normalized() 
#		positions[1] = positions[1].normalized() 
#		var plane_point : Vector3 = global_transform.origin + plane_normal * plane_distance
#		positions[0] = global_transform.origin + positions[0] * _calc_plane_x_ray_hit(plane_normal, plane_point, positions[0], global_transform.origin)
#		positions[1] = global_transform.origin + positions[1] * _calc_plane_x_ray_hit(plane_normal, plane_point, positions[1], global_transform.origin)
#		positions[0] = to_local(positions[0])
#		positions[1] = to_local(positions[1])
#		var hh = abs(positions[0].y - positions[1].y)
#		print("HH" + String(hh))
#		var ww = abs(positions[1].x - positions[1].x)
#		print("WW" + String(ww))
#		camera_distance = max(5 * sqrt(2), max(hh / fov_tangent, ww / fov_tangent))
#		print(camera_distance)
#		#var projected_player1_pos : Vector2 = unproject_position(global_transform.origin + distances[0])
#		#var projected_player2_pos : Vector2 = unproject_position(global_transform.origin + distances[1])
#		#var hh : float = abs(projected_player1_pos.y - projected_player2_pos.y) - edge_border
#		#camera_distance = hh / fov_tangent
#		#var fov_change : float = atan((abs(projected_player1_pos.y - projected_player2_pos.y) + edge_border) / (2 * global_transform.origin.distance_to((distances[0] + distances[1]) * 0.5)));
#		#fov = min(max(70, rad2deg(fov_change)), 90)
#		cam_position = at_target + distance_translation.normalized() * camera_distance
	look_at_from_position(cam_position, at_target, VECTOR_UP)
		
			
func _get_player_dependant_fov(player_origin : Vector3) -> float:
	var ret : float = 0.0
	var projected_pos = unproject_position(player_origin)
	#ret = max(atan(a
	return ret
	
func _calc_plane_x_ray_hit(plane_normal : Vector3, plane_origin : Vector3, ray_normal : Vector3, ray_origin : Vector3) -> float:
	var result : float = plane_normal.dot(plane_origin) - plane_normal.dot(ray_origin)
	result /= plane_normal.dot(ray_normal)
	return result
			
func _set_players_container() -> void:
	players_container = $"../StuffOnScreen/Players"