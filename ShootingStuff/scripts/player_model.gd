extends Spatial

export(Texture) var texture

func _ready():
	var mesh = find_node("Mesh 2", true, false) as MeshInstance
	var material = mesh.get_surface_material(0).duplicate() as SpatialMaterial
	material.albedo_texture = texture
	mesh.set_surface_material(0, material)