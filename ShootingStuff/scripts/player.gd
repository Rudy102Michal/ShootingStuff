extends Node

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

export(Texture) var texture
var readiness = false
var player_node: Spatial setget set_player_node
var look_direction: Vector3
var walk_direction = Vector2(0, 0)
var sprint: bool
var shoot: bool
var grenade: bool
	
func set_player_node(node: Spatial):
	player_node = node
	player_node.set('player', self)

#func _ready():
#	var mesh = find_node("Mesh 2", true, false) as MeshInstance
#	var material = mesh.get_surface_material(0).duplicate() as SpatialMaterial
#	material.albedo_texture = texture
#	mesh.set_surface_material(0, material)	
	
