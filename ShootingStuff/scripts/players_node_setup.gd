extends Spatial

const keyboard_control_resource = preload("res://scenes/Keyboard_Control_Node.tscn")
const gamepad_control_resource = preload("res://scenes/Gamepad_Control_Node.tscn")

# TODO: Make it not hard-coded, also dynamically load players,
# 		based on settings/preferances set with main menu/lobby
func _ready():
	var keyboard_control = keyboard_control_resource.instance()
	$Player_A.attach_control_node(keyboard_control)
	var gamepad_control = gamepad_control_resource.instance()
	$Player_B.attach_control_node(gamepad_control)