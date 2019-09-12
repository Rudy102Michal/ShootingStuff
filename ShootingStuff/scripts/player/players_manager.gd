extends Node

const Character = preload("res://scripts/player/player_character.gd")
const Device = preload("res://scripts/input_devices/device.gd")

export(Array, Texture) var textures
export(Array, AudioStream) var join_sounds
export(NodePath) var sound_player
export(NodePath) var grenade_manager

onready var ui_node = get_tree().get_root().find_node("Interface", true, false)

func _on_player_joined():
	var index = global.players.size() - 1
	var player_node_name = global.PLAYER_NAMES[index]
	var player_node = get_tree().get_root().find_node(player_node_name, true, false) as Spatial
	player_node.visible = true
	if player_node is Character:
		set_player_ingame_node_data(player_node, player_node_name)
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
		if global.players.size() > i:
			global.players[i].player_node = player_node
			var ingame_player = player_node as Character
			if ingame_player != null:
				set_player_ingame_node_data(ingame_player, global.PLAYER_NAMES[i])
		else:
			player_node.visible = false
			
		var mesh = player_node.find_node("Mesh", true, false) as MeshInstance
		var material = mesh.get_surface_material(0).duplicate() as SpatialMaterial
		material.albedo_texture = textures[i]
		mesh.set_surface_material(0, material)
	global.connect("player_joined", self, "_on_player_joined")
	global.connect("controller_disconnected", self, "_on_player_left")
	
func set_player_ingame_node_data(ingame_player: Character, name: String):
	ingame_player.set_grenade_manager(get_node(grenade_manager))
	ingame_player.set_player_name(name)
	if ui_node != null:
		var result : bool = ui_node.register_player(ingame_player)
		if result == false:
			print("Game UI interface couldn't register a player")