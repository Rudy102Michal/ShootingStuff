extends Node

# NOTE: Use 'Keyboard_Control.gd' as a point of reference.
#		As 'player' node calls this node with no regard to wether it's
#		gamepad or keyboard one, the abtract interaface should be 
#		the same as for 'Keyboard_Control.gd'

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

var player_node : KinematicBody

func _ready():
	player_node = null
	
func _input(event):
	pass

func should_move_forward() -> bool:
	return false
	
func should_move_backward() -> bool:
	return false
	
func should_start_sprint() -> bool:
	return false
	
func should_stop_sprint() -> bool:
	return false
	
func attach_player_node(node : KinematicBody) -> void:
	player_node = node