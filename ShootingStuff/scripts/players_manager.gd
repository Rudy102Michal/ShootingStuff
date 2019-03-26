extends Node

var players = [
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

func _ready():
	for player in players:
		var player_node = get_tree().get_root().find_node(player, true, false) as Spatial
		player_node.visible = false

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if !connected_devices.has(DEVICE_TYPE.KEYBOARD):
			player_joined(DEVICE_TYPE.KEYBOARD)
		elif event.scancode == KEY_ESCAPE:
			player_left(DEVICE_TYPE.KEYBOARD)
	elif event is InputEventJoypadButton and event.pressed:
		if !connected_devices.has(DEVICE_TYPE.PAD_1 + event.device):
			player_joined(DEVICE_TYPE.PAD_1 + event.device)
		elif event is InputEventJoypadButton and event.button_index == 1: #B
			player_left(DEVICE_TYPE.PAD_1 + event.device)

func player_joined(device):
	if connected_devices.size() < players.size():
		connected_devices[device] = players[connected_devices.size()]
		update_players()
		
func player_left(device):
	connected_devices.erase(device)
	update_players()
			
func update_players():
	for player in players:
		var player_node = get_tree().get_root().find_node(player, true, false) as Spatial
		player_node.visible = connected_devices.values().has(player)
	var GameLobbyHud = get_tree().get_root().find_node("GameLobbyHUD", true, false) as Node2D
	GameLobbyHud.menu_visible = connected_devices.size() > 0
	GameLobbyHud.invitation_visible = connected_devices.size() < players.size()