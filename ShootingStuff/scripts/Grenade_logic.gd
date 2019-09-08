extends RigidBody

var hit_something : bool = false
var thrown : bool = false
var delayed_trigger : float = 2.5	# in seconds
var delayed_trig_timer : Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# warning-ignore:unused_argument
func collision(body):
	hit_something = true
	print("Grenade hit something, my dude")
	explode()

func set_thrown(value: bool) -> void:
	thrown = value
	if thrown:
		delayed_trig_timer = Timer.new()
		delayed_trig_timer.connect("timeout", self, "trigger_timeout_explosion")
		delayed_trig_timer.set_wait_time(delayed_trigger)
		add_child(delayed_trig_timer)
		delayed_trig_timer.start()

func set_hit_something(value: bool) -> void:
	hit_something = value
	
func set_velocity(vel: Vector3) -> void:
	apply_central_impulse(vel)
	
func trigger_timeout_explosion() -> void:
	explode()
	
func explode() -> void:
	var parent = get_parent()
	if parent != null:
		get_parent().grenade_hit(self)