extends KinematicBody

# Signals

# Constants
const GRAVITY : Vector3 = Vector3(0.0, -9.8, 0.0)
const MAX_SPEED : float = 4.0
const ACCELERATION : float  = 3.0
const DE_ACCELERATION : float = 7.0
#const ANGLE_STEP : int = 90
const JUMP_SPEED : float = 3.5
const FLOOR_NORMAL : Vector3 = Vector3(0, 1.0, 0.0)

# Controls
var control_node : Node

# Movement
var velocity : Vector3


func _ready():
	# Temporary, later should be set to null and attached with function
	control_node = $Keyboard_Control
	control_node.attach_player_node(self)
	
	velocity = Vector3(0.0, 0.0, 0.0)
	
func _physics_process(delta):
	handle_player_movement(delta)
	
func handle_player_movement(delta):
	var front_vec : Vector3 = get_global_transform().basis.z
	var left_vec : Vector3 = FLOOR_NORMAL.cross(front_vec)
	var direction : Vector3 = Vector3(0.0, 0.0, 0.0)
	
	if control_node.should_move_forward():
		direction += front_vec
	if control_node.should_move_backward():
		direction += -front_vec
		
	direction.y = 0.0
	direction = direction.normalized()
	
	velocity += delta * GRAVITY
	
	var hv : Vector3 = velocity
	hv.y = 0
	
	var new_pos : Vector3 = direction * MAX_SPEED
	var acceleration = ACCELERATION if direction.dot(hv) > 0 else DE_ACCELERATION
	
	hv = hv.linear_interpolate(new_pos, acceleration * delta)
	hv.y = 0.0
	
	velocity.x = hv.x
	velocity.z = hv.z
	
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	

func attach_control_node(node : Node) -> void:
	add_child(node)
	control_node = node
	# Other stuff to trigger, maybe