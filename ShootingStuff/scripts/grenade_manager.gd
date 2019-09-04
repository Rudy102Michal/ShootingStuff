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
	
func blast_finished(blast : Node) -> void:
	$Blasts.remove_child(blast)
	blast.visible = false
	blast.queue_free()