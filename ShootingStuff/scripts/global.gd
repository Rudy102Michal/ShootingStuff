extends Node

const Device = preload("res://scripts/InputDevices/device.gd")
const Gamepad = preload("res://scripts/InputDevices/gamepad.gd")
const Keyboard = preload("res://scripts/InputDevices/keyboard.gd")
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

var players: Array = []
var connected_devices: Dictionary = { 0: Keyboard.new() }

func _init():
	for pad_id in Input.get_connected_joypads():
		connected_devices[DEVICE_TYPE.PAD_1 + pad_id] = Gamepad.new(pad_id)

func _on_joy_connection_changed(device_id, connected):
	pass