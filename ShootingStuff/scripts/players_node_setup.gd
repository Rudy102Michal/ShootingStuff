extends Spatial

const keyboard_control_resource = preload("res://scenes/Keyboard_Control_Node.tscn")
const gamepad_control_resource = preload("res://scenes/Gamepad_Control_Node.tscn")

# TODO: Make it (^) not hard-coded
# - players are now loaded automatically

func _ready():
	var keyboard_control = keyboard_control_resource.instance()
	var gamepad_control = gamepad_control_resource.instance()
	
	if global.connected_devices.size() == 0:
		# This "if" is for test purposes only - when playing ONLY playground.tscn (not from GameLobby)
		$PlayerA.attach_control_node(keyboard_control)
		# $PlayerB.queue_free()
		return
		
	# We check if player is connected. If yes, we attach control device, if not, we queue_free him
	
	for player in global.PLAYERS:
		var player_node = get_node(player) as KinematicBody
		if global.connected_devices.values().has(player):
			player_node.attach_control_node(keyboard_control if player == "PlayerA" else gamepad_control)
			# TODO: This is ugly as hell, I know ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		else:
			player_node.queue_free()