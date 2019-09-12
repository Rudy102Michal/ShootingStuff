extends KinematicBody

# constants
const GRAVITY : Vector3 = Vector3(0.0, -20.0, 0.0)
const MAX_SPEED : float = 2.0
const ACCELERATION : float  = 3.0
const DE_ACCELERATION : float = 7.0
#const ANGLE_STEP : int = 90
const JUMP_SPEED : float = 3.5
const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const MAX_ROTATION_ANGLE : float = PI * 0.75;
const VIEW_DISTANCE : float = 50.0
const DEMOGORGON_FOV : float = PI * 0.9 # about 160 degrees
const AGGRO_MOD : float = 3.0

# Controls
var animation_tree : AnimationTree 

# Movement
var velocity : Vector3
var old_velocity : Vector3

# Patrolling & rotation
var patrolling = true
var rotating_on_patrol : bool = false
var angle_to_rotate_to : float
var angle_already_rotated : float = 0.0

# Attacking
var attacking : bool = false
var attacking_time : float = 0.0
const attacking_anim_time_blend : float = 0.3
var players_in_range : int = 0

# Collision shapes
onready var col_shape_patrolling : CollisionShape = $Demog_Body_CS
onready var col_shape_running : CollisionShape = $Demog_Body_Run_CS

# Players data
var players_container : Spatial setget set_players_container
var seen_player : KinematicBody = null
var alive : bool
var can_move : bool

func _ready():
	velocity = Vector3(0.0, 0.0, 0.0)
	old_velocity = velocity
	if players_container == null: # This is for test purposes only
		set_players_container(get_node("../../Players"))
	animation_tree = $RotationHelper/Model/AnimationTree
	col_shape_running.disabled = true
	alive = true
	can_move = true

func _physics_process(delta):
	if not alive or not can_move:
		return
	if patrolling:
		patrol_and_rotate(delta)
		check_if_player_seen()
	else:
		rotate_towards_seen_player(delta)
	if players_in_range > 0:
		patrolling = false
		attacking_time = min(attacking_anim_time_blend, attacking_time + delta)
		attack()
	else:
		attacking_time = max(0.0, attacking_time - delta)
		attacking = false
	handle_movement(delta)
	
func rotate_towards_seen_player(delta):
	
	# TODO: Make the rotation towards player less abrupt
	if seen_player != null:
		var player_position = seen_player.global_transform.origin
		look_at(player_position, VECTOR_UP)

func attack() -> void:
	attacking = true
	var blend_am = 1.0 - smoothstep(0.0, attacking_anim_time_blend, attacking_time)
	animation_tree.set("parameters/Blend2_Attack/blend_amount", blend_am)
	attacking_time = min(attacking_time, attacking_anim_time_blend)
		
func patrol_and_rotate(delta):
	if not rotating_on_patrol:
		# roll to check if rotate, if yes - get rotation angle
		var roll_to_rotate_enemy = rand_range(0, 90)
		if roll_to_rotate_enemy <= 1: # chance hardcoded above
			rotating_on_patrol = true
			angle_already_rotated = 0.0
			angle_to_rotate_to = rand_range(-MAX_ROTATION_ANGLE, MAX_ROTATION_ANGLE)
	else:
		# rotation logic
		var lerped_rotation_value = lerp(angle_already_rotated, angle_to_rotate_to, delta)
		self.global_rotate(VECTOR_UP, lerped_rotation_value - angle_already_rotated)
		angle_already_rotated = lerped_rotation_value
		if abs(angle_to_rotate_to - angle_already_rotated) <= PI/180.0: # 1 degree
			rotating_on_patrol = false;
	pass
	
func check_if_player_seen():
	if players_container == null: # Shouldn't happen, but still
		return
	
	var front_vec : Vector3 = -get_global_transform().basis.z
	front_vec.y = 0;
	for player in players_container.get_children():
		if player.visible == false:
			break

		var vector_to_player = player.translation - self.translation
		vector_to_player.y = 0;
		if vector_to_player.length() > VIEW_DISTANCE: # cannot see that player, it's too far
			continue
		var vector_dot = front_vec.dot(vector_to_player)
		var angle_between_vectors = front_vec.angle_to(vector_to_player)
		if abs(angle_between_vectors) <= DEMOGORGON_FOV / 2.0:
			# player spotted, the hunt begins
			seen_player = player
			patrolling = false
			col_shape_patrolling.disabled = true
			col_shape_running.disabled = false
			animation_tree["parameters/OneShot_Roar/active"] = true
			animation_tree["parameters/Blend2/blend_amount"] = 1.0
			$RotationHelper/Model/RoarSoundPlayer.play()
			return
	
func handle_movement(delta):
		
	var front_vec : Vector3 = -get_global_transform().basis.z
	var left_vec : Vector3 = VECTOR_UP.cross(front_vec)
	var direction : Vector3 = Vector3(0.0, 0.0, 0.0)
	
	if attacking_time > 0.0 and not attacking:
		animation_tree.set("parameters/Blend2_Attack/blend_amount", smoothstep(attacking_anim_time_blend, 0.0, attacking_time))
	
	direction += front_vec
	direction.y = 0.0
	direction = direction.normalized()
	
	velocity += delta * GRAVITY
	
	var hv : Vector3 = velocity
	hv.y = 0
	
	var new_pos : Vector3 = direction * (MAX_SPEED * AGGRO_MOD if (not patrolling) else MAX_SPEED)
	var acceleration = ACCELERATION if direction.dot(hv) > 0 else DE_ACCELERATION
	acceleration = acceleration * AGGRO_MOD if (not patrolling) else acceleration
	acceleration = acceleration if not attacking else 0.0
	hv = hv.linear_interpolate(new_pos, acceleration * delta)
	hv.y = 0.0
	
	velocity.x = hv.x
	velocity.z = hv.z
	
	var distance_from_player = 0
	
	if (seen_player):
		var v1 = seen_player.to_global(Vector3.ZERO)
		var v2 = to_global(Vector3.ZERO)
		distance_from_player = Vector2(v1.x, v1.z).distance_to(Vector2(v2.x, v2.z))
	
	if not (animation_tree["parameters/OneShot_Roar/active"] or (seen_player and distance_from_player < 2)):
		velocity = move_and_slide(velocity, VECTOR_UP)
	
func set_players_container(value):
	players_container = value
	
func get_self_2d_position() -> Vector2:
	return Vector2(global_transform.origin.x, global_transform.origin.z)
	
func kill_yourself():
	can_move = false
	animation_tree.set("parameters/OneShot_Death/active", true)
#	queue_free()

func recoil_from_explosion(recoil_force : Vector3) -> void:
	velocity += recoil_force
	
func gorgon_dies() -> void:
	alive = false
	animation_tree.active = false
	animation_tree
		

func _on_AttackRange_body_entered(body):
	var player : PlayerCharacter = body as PlayerCharacter
	if player != null:
		print("Player in range!")
		players_in_range += 1


func _on_AttackRange_body_exited(body):
	var player : PlayerCharacter = body as PlayerCharacter
	if player != null:
		print("Farewell player!")
		players_in_range = max(0, players_in_range - 1)			# In theory < 0 shouldn't happen, but if does,
																# then may fuck up a lot


func _on_PawArea_hit_player(body):
	var player : PlayerCharacter = body as PlayerCharacter
	if player != null:
		print("Hit dat player!")
		player.get_hit(0.1) 		# Should be better, but oh, well..
