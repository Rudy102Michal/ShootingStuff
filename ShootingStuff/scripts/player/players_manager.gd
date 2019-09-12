extends Node

const Character = preload("res://scripts/player/player_character.gd")
const Device = preload("res://scripts/input_devices/device.gd")

export(Array, Texture) var textures
export(Array, AudioStream) var join_sounds
export(NodePath) var sound_player
export(NodePath) var grenade_manager

func _on_player_joined():
	var index = global.players.size() - 1
	var player_node_name = global.PLAYER_NAMES[index]
	var player_node = get_tree().get_root().find_node(player_node_name, true, false) as Spatial
	player_node.visible = true
	if player_node is Character:
		player_node.player_name = player_node_name
	global.players[index].player_node = player_node

	var sp = get_node(sound_player)
	sp.stream = join_sounds[index]
	sp.play()

func _on_player_left(device: Device):
	if not device.player.player_node is Character:
		device.player.player_node.visible = false
		global.players.erase(device.player)
		device.player = null

func _ready():
	for i in global.PLAYER_NAMES.size():
		var player_node = get_tree().get_root().find_node(global.PLAYER_NAMES[i], true, false) as Spatial
		var ui = get_tree().get_root().find_node("Interface", true, false)
		if global.players.size() > i:
			global.players[i].player_node = player_node
			var ingame_player = player_node as PlayerCharacter
			if ingame_player != null:
				ingame_player.set_grenade_manager(get_node(grenade_manager))
				player_node.set_player_name(global.PLAYER_NAMES[i])			# something nicer, maybe?
				if ui != null:
					var result : bool = ui.register_player(player_node)
					if result == false:
						print("Game UI interface couldn't register a player")
		else:
			player_node.visible = false
			
		var mesh = player_node.find_node("Mesh", true, false) as MeshInstance
		var material = mesh.get_surface_material(0).duplicate() as SpatialMaterial
		material.albedo_texture = textures[i]
		mesh.set_surface_material(0, material)
	global.connect("player_joined", self, "_on_player_joined")
	global.connect("controller_disconnected", self, "_on_player_left")