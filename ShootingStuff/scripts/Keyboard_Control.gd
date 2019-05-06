extends Node

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

var player_node : KinematicBody
#var last_mouse_pos : Vector2 = Vector2(0, 0)

func _ready():
	player_node = null
	
func _input(event):
	if player_node != null and event is InputEventMouseMotion:
		var player_pos : Vector3 = player_node.get_global_transform().origin
		var player_front : Vector3 = player_node.get_global_transform().basis.z + player_pos
		var camera : Camera = get_viewport().get_camera()
		var projected_player_pos : Vector2 = camera.unproject_position(player_pos)
		var projected_player_front : Vector2 = camera.unproject_position(player_front)
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var pm = mouse_pos - projected_player_pos
		var pf = projected_player_front - projected_player_pos
		player_node.global_rotate(VECTOR_UP, pm.angle_to(pf))

func should_move() -> bool:
	return (Input.is_action_pressed("move_forward")
	or Input.is_action_pressed("move_backward")
	or Input.is_action_pressed("move_left")
	or Input.is_action_pressed("move_right"))
	
func get_move_direction() -> Vector3:
	var control_vector = Vector2(0.0, 0.0)
	if Input.is_action_pressed("move_forward"): control_vector += Vector2(0.0, -1.0)
	if Input.is_action_pressed("move_backward"): control_vector += Vector2(0.0, 1.0)
	if Input.is_action_pressed("move_left"): control_vector += Vector2(-1.0, 0.0)
	if Input.is_action_pressed("move_right"): control_vector += Vector2(1.0, 0.0)
	
	# TODO: This does not take into account the rotation of camera
	# (assumes it is parralel to "forward" direction, which it currently is)
	# robably would need some unprojecting and/or rotation of control_vector
	
	return Vector3(control_vector.x, 0.0, control_vector.y)
	
func should_start_sprint() -> bool:
	return Input.is_action_just_pressed("move_sprint")

func should_stop_sprint() -> bool:
	return Input.is_action_just_released("move_sprint")
	
func attach_player_node(node : KinematicBody) -> void:
	player_node = node