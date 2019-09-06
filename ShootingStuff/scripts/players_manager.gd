extends Node

const Character = preload("res://scripts/player_character.gd")
const Device = preload("res://scripts/input_devices/device.gd")

export(Texture) var texture

func _on_player_joined():
	var player_name = global.PLAYER_NAMES[global.players.size() - 1]
	var player_node = get_tree().get_root().find_node(player_name, true, false) as Spatial
	player_node.visible = true
	global.players[global.players.size() - 1].player_node = player_node

func _on_player_left(device: Device):
	if not device.player.player_node is Character:
		device.player.player_node.visible = false
		global.players.erase(device.player)
		device.player = null

func _ready():
	for i in global.PLAYER_NAMES.size():
		var player_node = get_tree().get_root().find_node(global.PLAYER_NAMES[i], true, false) as Spatial
		if global.players.size() > i:
			global.players[i].player_node = player_node
		else:
			player_node.visible = false
			
		var mesh = player_node.find_node("Mesh 2", true, false) as MeshInstance
		var material = mesh.get_surface_material(0).duplicate() as SpatialMaterial
		material.albedo_texture = texture
		mesh.set_surface_material(0, material)
	global.connect("player_joined", self, "_on_player_joined")
	global.connect("controller_disconnected", self, "_on_player_left")