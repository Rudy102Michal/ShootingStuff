extends Node

# NOTE: Use 'Keyboard_Control.gd' as a point of reference.
#		As 'player' node calls this node with no regard to wether it's
#		gamepad or keyboard one, the abtract interaface should be 
#		the same as for 'Keyboard_Control.gd'

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const DEVICE = 0 # TODO: this probably shouldnt be hardcoded

var player_node : KinematicBody

func _ready():
	player_node = null
	
func _input(event):
	if player_node != null and event is InputEventJoypadMotion:
		var right_analog_axis = Vector2(Input.get_joy_axis(DEVICE, JOY_AXIS_2), -Input.get_joy_axis(DEVICE, JOY_AXIS_3))
		# TODO: Also does not take into account camera rotation
		player_node.rotation = VECTOR_UP * (right_analog_axis.angle() + PI/2)

func should_move() -> bool:
	return (abs(Input.get_joy_axis(DEVICE, JOY_AXIS_0)) >= 0.1
	or abs(Input.get_joy_axis(DEVICE, JOY_AXIS_1)) >= 0.1) # this is not quite 0 "at rest"
	
func get_move_direction() -> Vector3:
	var base_vector = Vector3(1.0, 0.0, 0.0)
	var angle = Vector2(Input.get_joy_axis(DEVICE, JOY_AXIS_0), -Input.get_joy_axis(DEVICE, JOY_AXIS_1)).angle()
	return base_vector.rotated(VECTOR_UP, angle)
	
func should_start_sprint() -> bool:
	return Input.is_action_just_pressed("move_sprint")
	
func should_stop_sprint() -> bool:
	return Input.is_action_just_released("move_sprint")
	
func attach_player_node(node : KinematicBody) -> void:
	player_node = node