extends Camera

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const CAMERA_SPEED : float = 4.0
const edge_border : float = 20.0
const camera_distance: float = 12 * sqrt(2.0)

var players_container : Spatial
var distance_translation : Vector3

var camera_angle : float = PI / 6.0
var fov_tangent : float

var at_target : Vector3
var cam_position : Vector3

func _ready():
	_set_players_container()
	fov_tangent = 2.0 * tan(deg2rad(fov / 2.0))
	distance_translation = Vector3(0.0, 1.0, 1.0)
	distance_translation = distance_translation.normalized()
	cam_position = get_global_transform().origin
	at_target = $"../StuffOnScreen/Portal".translation

func _physics_process(delta):
	if players_container == null:
		_set_players_container()
		return
		
	var old_cam_pos = get_global_transform().origin
	
	var players : Array = []
	for p in players_container.get_children():
		if p.visible and p.alive:
			players.push_back(p)
			
	if players.size() == 1:
		at_target = players[0].global_transform.origin
		cam_position = at_target + distance_translation * camera_distance
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
		d = max(d, camera_distance)
		
		cam_position = at_target + distance_translation.normalized() * d
	$"../Listener".translation = at_target
	look_at_from_position(old_cam_pos.linear_interpolate(cam_position, delta * CAMERA_SPEED), at_target, VECTOR_UP)
			
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