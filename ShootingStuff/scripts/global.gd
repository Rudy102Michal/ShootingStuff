extends Node

const PLAYERS = [
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

var connected_devices = {}