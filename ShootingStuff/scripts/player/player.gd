extends Node

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

export(Texture) var texture
var readiness = false
var player_node: Spatial setget set_player_node
var look_direction = Vector2(0, 1)
var walk_direction = Vector2(0, 0)
var sprint: bool
var shoot: bool
var grenade: bool
	
func set_player_node(node: Spatial):
	player_node = node
	player_node.set('player', self)
