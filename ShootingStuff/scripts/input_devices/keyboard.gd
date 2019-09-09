extends "res://scripts/input_devices/device.gd"
class_name Keyboard

const Character = preload("res://scripts/player/player_character.gd")

func handleInput(event: InputEvent):
	if (event is InputEventMouseMotion and player != null
	and player.player_node is Character):
		player.player_node.update_rotation_from_mouse_position()
	elif (event is InputEventKey):
		if (event.is_action_pressed("ui_up")):
			player.walk_direction.y = -1
		elif (event.is_action_pressed("ui_down")):
			player.walk_direction.y = 1
		elif (event.is_action_released("ui_up") and player.walk_direction.y == -1
		  or event.is_action_released("ui_down") and player.walk_direction.y == 1):
			player.walk_direction.y = 0
		elif (event.is_action_pressed("ui_left")):
			player.walk_direction.x = -1
		elif (event.is_action_pressed("ui_right")):
			player.walk_direction.x = 1
		elif (event.is_action_released("ui_left") and player.walk_direction.x == -1
		  or event.is_action_released("ui_right") and player.walk_direction.x == 1):
			player.walk_direction.x = 0
	.handleInput(event)