extends KinematicBody

class_name PlayerCharacter

signal player_health_changed(player_node, health_value)
signal player_weapon_changed(player_node, weapon_name)

const Player = preload("res://scripts/player/player.gd")
const Grenade = preload("res://prefabs/Equipment/Grenade.tscn")
	
# Constants
const GRAVITY : float = -20.0
const ACCELERATION : float  = 3.0
const DE_ACCELERATION : float = 7.0
const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)
const WALK_SPEED : float = 4.0
const RUN_SPEED : float = 10.0

# Game-wise traits
var player_name : String = ""
var health_points : float = 1.0		# as a percentage, i.e. [0.0, 1.0]


# Variables
var player: Player setget set_player
var animation_tree : AnimationTree

var velocity : Vector3

# Weapons
var weapons_node : BoneAttachment
var weapons_node_left : BoneAttachment
var current_weapon_node : MeshInstance
var shooting_node : Spatial
var weapons_count : int

# Grenades
export(NodePath) var grenade_manager
var current_nade = null

func _ready():
	set_physics_process(false)
	velocity = Vector3(0.0, 0.0, 0.0)
	animation_tree = $Rotation_Helper/Model/AnimationTree
	weapons_node = find_node("Weapon")
	weapons_node_left = find_node("WeaponLeftHand")
	current_weapon_node = make_weapon_visible(0) # starting weapon is xcom_rifle
	weapons_count = min(weapons_node.get_child_count(), weapons_node_left.get_child_count())
	shooting_node = $"../../Bullets"
	
func set_player(p: Player):
	player = p
	set_physics_process(true)
	player.connect("player_change_weapon", self, "change_weapon")
	player.connect("player_throw_grenade", self, "throw_grenade")

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
		yield(get_tree().create_timer(0.1), "timeout")
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

func change_weapon():
	for index in range(weapons_count):
		if weapons_node.get_children()[index].visible:
			var next_w_ind : int = index + 1 if index < (weapons_count - 1) else 0
			current_weapon_node = make_weapon_visible(next_w_ind)
			emit_signal("player_weapon_changed", self, get_current_weapon_name())
			return

func make_weapon_visible(w_ind : int) -> MeshInstance:
	for weapon in weapons_node.get_children() + weapons_node_left.get_children():
		weapon.visible = false
	weapons_node.get_children()[w_ind].visible = true
	weapons_node_left.get_children()[w_ind].visible = true
	return weapons_node.get_children()[w_ind]

func get_barrel_position() -> Position3D:
	return current_weapon_node.get_node("./BarrelPosition") as Position3D

func pick_up_grenade():
	var new_grenade : RigidBody = Grenade.instance()
	new_grenade.add_collision_exception_with(self)
	new_grenade.set_mode(RigidBody.MODE_KINEMATIC)
	$"Rotation_Helper/Model/Skeleton/BA_RightHand".add_child(new_grenade, true)
	current_nade = new_grenade
	
func throw_grenade():
	animation_tree.set("parameters/OneShot_Grenade/active", true)
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
		
		
# UI specific

func get_player_name() -> String:
	return player_name
	
func set_player_name(p_name : String) -> void:
	player_name = p_name
	
func get_current_weapon_name() -> String:
	return current_weapon_node.name