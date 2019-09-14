extends "res://scripts/input_devices/device.gd"
class_name Gamepad

const Character = preload("res://scripts/player/player_character.gd")

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
var deviceId: int
var aiming: bool

func _init(deviceId: int):
	self.deviceId = deviceId

func handleInput(event: InputEvent):
	if (player and player.player_node is Character):
		if event is InputEventJoypadMotion:
			var holding = abs(event.axis_value) > 0.25
			if (event.axis == JOY_AXIS_0):
				player.walk_direction.x = event.axis_value if holding else 0
				if holding and not aiming:
					player.look_direction.x = player.walk_direction.x
					updateRotation()
			elif (event.axis == JOY_AXIS_1):
				player.walk_direction.y = event.axis_value if holding else 0
				if holding and not aiming:
					player.look_direction.y = -player.walk_direction.y
					updateRotation()
			elif (event.axis == JOY_AXIS_2 or event.axis == JOY_AXIS_3):
				if (abs(Input.get_joy_axis(deviceId, JOY_AXIS_2)) < 0.4
					and abs(Input.get_joy_axis(deviceId, JOY_AXIS_3)) < 0.4):
					aiming = false
					if not (player.walk_direction.x == 0 and player.walk_direction.y == 0):
						player.look_direction.x = player.walk_direction.x
						player.look_direction.y = -player.walk_direction.y
						updateRotation()
				else:
					aiming = true
					player.look_direction = Vector2(Input.get_joy_axis(deviceId, JOY_AXIS_2), -Input.get_joy_axis(deviceId, JOY_AXIS_3))
					updateRotation()	
	.handleInput(event)
	
func updateRotation():
	if player.player_node.alive:
		player.player_node.rotation = VECTOR_UP * (player.look_direction.angle() + PI/2)
