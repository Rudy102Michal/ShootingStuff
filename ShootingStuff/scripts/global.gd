extends Node

const Device = preload("res://scripts/input_devices/device.gd")
const Gamepad = preload("res://scripts/input_devices/gamepad.gd")
const Keyboard = preload("res://scripts/input_devices/keyboard.gd")
const Player = preload("res://scripts/player.gd")

const PLAYER_NAMES = [
	"PlayerA",
	"PlayerB",
	#"PlayerC",
	#"PlayerD",
]

enum DEVICE_TYPE {
	KEYBOARD,
	PAD_1,
	PAD_2,
	PAD_3,
	PAD_4,
}

signal player_joined
signal controller_disconnected

var players: Array = []
var connected_devices: Dictionary = { 0: Keyboard.new() }

func _init():
	for device_id in Input.get_connected_joypads():
		connected_devices[DEVICE_TYPE.PAD_1 + device_id] = Gamepad.new(device_id)

func _on_joy_connection_changed(device_id, connected):
	if connected:
		connected_devices[DEVICE_TYPE.PAD_1 + device_id] = Gamepad.new(device_id)
	else:
		if connected_devices[DEVICE_TYPE.PAD_1 + device_id].player != null:
			emit_signal("controller_disconnected")
		connected_devices.erase(DEVICE_TYPE.PAD_1 + device_id)
	pass

func _input(event):
	# 1. Map input source to a correct device object.
	var device: Device
	if event is InputEventKey or event is InputEventMouse:
		device = connected_devices[DEVICE_TYPE.KEYBOARD]
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		device = connected_devices[DEVICE_TYPE.PAD_1 + event.device]
	
	# 2. If device was found
	if device:
		# 3. If no player connected with this device yet, join game
		if (device.player == null
			and not event is InputEventMouseMotion # but not with mouse movement
			and players.size() < PLAYER_NAMES.size()):
			device.player = Player.new()
			players.push_back(device.player)
			emit_signal("player_joined")

		# 4. Otherwise pass the input to the correct device.
		else:
			device.handleInput(event)