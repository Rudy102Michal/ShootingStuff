extends KinematicBody

const Player = preload("res://scripts/player/player.gd")
	
# Constants
const GRAVITY : float = -9.8
const ACCELERATION : float  = 3.0
const DE_ACCELERATION : float = 7.0
const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const WALK_SPEED : float = 4.0
const RUN_SPEED : float = 10.0

# Variables
var player: Player setget set_player
var animation_tree : AnimationTree

var velocity : Vector3

# Weapons
var weapons_node : BoneAttachment
var current_weapon_node : MeshInstance
var shooting_node : Spatial
var weapons_count : int

# Grenades
export(NodePath) var grenade_manager
onready var grenade = preload("res://prefabs/Equipment/Grenade.tscn")
var current_nade = null

func _ready():
	set_physics_process(false)
	velocity = Vector3(0.0, 0.0, 0.0)
	animation_tree = $Rotation_Helper/Model/AnimationTree
	weapons_node = find_node("Weapon")
	for weapon in weapons_node.get_children():
		weapon.visible = false
	current_weapon_node = weapons_node.get_children()[0] # starting weapon is xcom_rifle
	current_weapon_node.visible = true
	weapons_count = weapons_node.get_child_count()
	shooting_node = $"../../Bullets"
	
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
		shooting_node.shoot(get_barrel_position(), current_weapon_node.name)
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
		throw_grenade()
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

func get_barrel_position() -> Position3D:
	return current_weapon_node.get_node("./BarrelPosition") as Position3D

func pick_up_grenade():
	print("Hakuna granata")
	var new_grenade : RigidBody = grenade.instance()
	new_grenade.add_collision_exception_with(self)
	new_grenade.set_mode(RigidBody.MODE_KINEMATIC)
	$"Rotation_Helper/Model/Skeleton/BA_RightHand".add_child(new_grenade, true)
	current_nade = new_grenade
	
func throw_grenade():
	var gm : Node = get_node(grenade_manager)
	if current_nade != null:
		current_nade.set_mode(RigidBody.MODE_RIGID)
		var gtf : Transform = current_nade.get_global_transform()
		$"Rotation_Helper/Model/Skeleton/BA_RightHand".remove_child(current_nade)
		gm.add_child(current_nade, true)
		current_nade.global_transform = gtf
		var front_vec : Vector3 = get_global_transform().basis.z.normalized()
		var left_vec : Vector3 = VECTOR_UP.cross(front_vec)
		var nade_vel : Vector3 = front_vec.rotated(-left_vec, PI / 4.0) * 10
		current_nade.set_velocity(nade_vel)
		current_nade.set_thrown(true)
		current_nade = null