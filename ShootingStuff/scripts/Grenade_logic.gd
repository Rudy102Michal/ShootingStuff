extends RigidBody

var hit_something : bool = false
var collision_throw_delay : float = -1.0
var thrown : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# warning-ignore:unused_argument
func collision(body):
	hit_something = true
	print("Grenade hit something, my dude")
	var parent = get_parent()
	if parent != null:
		get_parent().grenade_hit(self)

func set_thrown(value: bool) -> void:
	thrown = value
	if thrown:
		collision_throw_delay = 0.0

func set_hit_something(value: bool) -> void:
	hit_something = value
	
func set_velocity(vel: Vector3) -> void:
	apply_central_impulse(vel)
	