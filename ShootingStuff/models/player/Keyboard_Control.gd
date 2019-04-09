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
		print(pf.angle_to(pm))
		player_node.global_rotate(VECTOR_UP, pm.angle_to(pf))

func should_move_forward() -> bool:
	return Input.is_action_pressed("move_forward")
	
func should_move_backward() -> bool:
	return Input.is_action_pressed("move_backward")
	
func attach_player_node(node : KinematicBody) -> void:
	player_node = node