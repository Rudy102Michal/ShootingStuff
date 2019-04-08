extends Node

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

var player_node : KinematicBody

func _ready():
	player_node = null
	
func _input(event):
	if player_node != null and event is InputEventMouseMotion:
		var target : Vector3 = event.relative - player_node
		player_node.look_at(event.relative, VECTOR_UP)

func should_move_forward() -> bool:
	return Input.is_action_pressed("move_forward")
	
func should_move_backward() -> bool:
	return Input.is_action_pressed("move_backward")
	
func attach_player_node(node : KinematicBody) -> void:
	player_node = node