extends MeshInstance

func _ready():
	$SpotLight.hide()

func shoot():
	$SpotLight.show()
	var particles_emitters = $ParticlesEmitters.get_children()
	for emitter in particles_emitters:
		emitter.emitting = true
	yield(get_tree().create_timer(0.1), "timeout")
	$SpotLight.hide()
