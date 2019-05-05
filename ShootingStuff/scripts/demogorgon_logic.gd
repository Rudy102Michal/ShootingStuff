extends KinematicBody

# constants
const GRAVITY : Vector3 = Vector3(0.0, -9.8, 0.0)
const MAX_SPEED : float = 2.0
const ACCELERATION : float  = 3.0
const DE_ACCELERATION : float = 7.0
#const ANGLE_STEP : int = 90
const JUMP_SPEED : float = 3.5
const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

# Controls
var animation_tree : AnimationTree 

# Movement
var velocity : Vector3
var old_velocity : Vector3

# Players data
var players_container : Spatial setget set_players_container

func _ready():
	velocity = Vector3(0.0, 0.0, 0.0)
	old_velocity = velocity
	#animation_tree = $Rotation_Helper/Model/AnimationTree
	pass

func _physics_process(delta):
	rotate_towards_nearest_player(delta)
	handle_movement(delta)
	pass
	
func rotate_towards_nearest_player(delta):
	
	# TODO: Add proper logic for it here
	if players_container != null:
		if players_container.get_child_count() > 0:
			var player_1_position = players_container.get_child(0).global_transform.origin
			look_at(player_1_position, VECTOR_UP)
	
func handle_movement(delta):
		
	var front_vec : Vector3 = -get_global_transform().basis.z
	var left_vec : Vector3 = VECTOR_UP.cross(front_vec)
	var direction : Vector3 = Vector3(0.0, 0.0, 0.0)
		
	direction += front_vec
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
	
	velocity = move_and_slide(velocity, VECTOR_UP)
	pass
	
func set_players_container(value):
	players_container = value
	pass
	
func get_self_2d_position() -> Vector2:
	return Vector2(global_transform.origin.x, global_transform.origin.z)
