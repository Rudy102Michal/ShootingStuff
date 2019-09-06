extends "res://scripts/input_devices/device.gd"
class_name Gamepad

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
var deviceId: int
var aiming: bool

func _init(deviceId: int):
	self.deviceId = deviceId
	
func updateRotation():
	var target_rotation = VECTOR_UP * (player.look_direction.angle() + PI/2)
	player.player_node.rotation = (player.player_node.rotation + target_rotation) / 2

func handleInput(event: InputEvent):
	if (event is InputEventJoypadMotion):
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
			if (holding):
				aiming = true
				player.look_direction = Vector2(Input.get_joy_axis(deviceId, JOY_AXIS_2), -Input.get_joy_axis(deviceId, JOY_AXIS_3))
				updateRotation()
			else:
				aiming = false
	.handleInput(event)
