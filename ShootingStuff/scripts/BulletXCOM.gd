extends KinematicBody

var timeout : float
var shot_direction : Vector3
var velocity : Vector3
var particle_scale : float
const SPEED = 0.3

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
		self.queue_free()
	var collision : KinematicCollision = move_and_collide(velocity)
	if collision != null:
		if collision.collider != null:
			if collision.collider.is_in_group("enemies"):
				shooting_manager.handle_hit(collision.collider)
		# TODO: maybe add some animation of bullet splashing
		self.queue_free()
