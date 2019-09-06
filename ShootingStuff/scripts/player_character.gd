extends KinematicBody

const GRAVITY : float = -9.8
const ACCELERATION : float  = 3.0
const DE_ACCELERATION : float = 7.0
const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const WALK_SPEED : float = 4.0
const RUN_SPEED : float = 10.0

const Player = preload("res://scripts/player.gd")

var player: Player setget set_player
var animation_tree : AnimationTree

var velocity : Vector3

func _ready():
	set_physics_process(false)
	velocity = Vector3(0.0, 0.0, 0.0)
	animation_tree = $Rotation_Helper/Model/AnimationTree
	
func set_player(p: Player):
	player = p
	set_physics_process(true)

func _physics_process(delta):
	var direction = Vector3(player.walk_direction.x, 0.0, player.walk_direction.y).normalized()
	var front_vec : Vector3 = get_global_transform().basis.z
	var max_speed = RUN_SPEED if player.sprint else WALK_SPEED
	
	var hv = Vector3(velocity.x, 0, velocity.z)
	var new_pos : Vector3 = direction * max_speed
	var acceleration = ACCELERATION if direction.dot(velocity) > 0 else DE_ACCELERATION
	
	hv = hv.linear_interpolate(new_pos, acceleration * delta)
	velocity.x = hv.x
	velocity.y += GRAVITY * delta
	velocity.z = hv.z
	velocity = move_and_slide(velocity, VECTOR_UP)
		
	if player.shoot:
		animation_tree.set("parameters/Blend2_1/blend_amount", 1.0)
	else:
		animation_tree.set("parameters/Blend2_1/blend_amount", 0.0)
	
	var walk_blend_value : float = min(velocity.length(), 1.0)
	walk_blend_value *= walk_blend_value
	walk_blend_value *= sign(direction.normalized().dot(front_vec))
	animation_tree.set("parameters/Blend3_1/blend_amount", walk_blend_value)
	animation_tree.set("parameters/Blend2_3/blend_amount", walk_blend_value)
	
	var sprint_blend_value : float = range_lerp(velocity.length(), WALK_SPEED, RUN_SPEED, 0.0, 1.0)
	animation_tree.set("parameters/Blend2_2/blend_amount", sprint_blend_value)
	
	if player.grenade:
		animation_tree.set("parameters/OneShot_Grenade/active", true)

func update_rotation_from_mouse_position():
	if player:
		var player_pos : Vector3 = get_global_transform().origin
		var player_front : Vector3 = get_global_transform().basis.z + player_pos
		var camera : Camera = get_viewport().get_camera()
		var projected_player_pos : Vector2 = camera.unproject_position(player_pos)
		var projected_player_front : Vector2 = camera.unproject_position(player_front)
		var mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var pm = mouse_pos - projected_player_pos
		var pf = projected_player_front - projected_player_pos
		global_rotate(VECTOR_UP, pm.angle_to(pf))
		player.look_direction = rotation