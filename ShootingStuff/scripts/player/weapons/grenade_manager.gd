extends Spatial

onready var impulse_blast = preload("res://prefabs/Equipment/ImpulseBlast.tscn")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func grenade_hit(grenade) -> void:
	var nade_pos : Vector3 = grenade.get_global_transform().origin
	grenade.hide()
	remove_child(grenade)
	grenade.queue_free()
	var blast : Spatial = impulse_blast.instance()
	blast.global_transform.origin = nade_pos
	$Blasts.add_child(blast)
	blast.set_manager(self)
#	var enemies = get_tree().get_nodes_in_group("enemies")
	var moving_entities = get_tree().get_nodes_in_group("enemies") + get_tree().get_nodes_in_group("players")
	for enemy in moving_entities:
		var ray : Vector3 = enemy.get_global_transform().origin - nade_pos
		var dist : float = ray.length()
		if dist < blast.max_radius:
			var force_vec : Vector3 = ray.normalized() * blast.recoil_force # / dist_sqr
			force_vec = force_vec.rotated(force_vec.cross(Vector3(0, 1, 0)).normalized(), PI / 4.0) * 10 * (blast.max_radius - dist)
			enemy.recoil_from_explosion(force_vec)
	
func blast_finished(blast : Node) -> void:
	$Blasts.remove_child(blast)
	blast.visible = false
	blast.queue_free()