extends KinematicBody

var timeout : float
var shot_direction : Vector3
var velocity : Vector3
var active = true
const SPEED = 25.0

onready var shooting_manager : Spatial = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	timeout = 1.0
	velocity = shot_direction * SPEED
	velocity.y = 0
	pass # Replace with function body.

func _physics_process(delta):
	timeout -= delta
	if timeout <= 0:
		velocity *= 0.8
		$Particles2.emitting = false
		$OmniLight.light_energy *= 0.8
		if $OmniLight.light_energy < 0.01:
			self.queue_free()
	if active:
		var collision : KinematicCollision = move_and_collide(velocity * delta)
		if collision != null:
			if collision.collider != null:
				if collision.collider.is_in_group("enemies"):
					shooting_manager.handle_hit(collision.collider)
			# TODO: maybe add some animation of bullet splashing
			active = false
			timeout = 0
