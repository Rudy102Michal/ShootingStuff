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
		#print(right_analog_axis.angle())
		player_node.rotation = VECTOR_UP * (right_analog_axis.angle() + PI/2)

func should_move_forward() -> bool:
	return Input.get_joy_axis(DEVICE, JOY_AXIS_1) < -0.1 # this is not quite 0 "at rest"
	
func should_move_backward() -> bool:
	#print(Input.get_joy_axis(DEVICE, JOY_AXIS_1))
	return Input.get_joy_axis(DEVICE, JOY_AXIS_1) > 0.1 # this is not quite 0 "at rest"
	
func should_start_sprint() -> bool:
	return Input.is_action_just_pressed("move_sprint")
	
func should_stop_sprint() -> bool:
	return Input.is_action_just_released("move_sprint")
	
func should_throw_grenade() -> bool:
	return false
	
func is_shooting() -> bool:
	return false
	
func attach_player_node(node : KinematicBody) -> void:
	player_node = node