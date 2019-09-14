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
var can_move : bool = false
var alive : bool = false
var velocity : Vector3
var throw_grenade_sound: AudioStream

# Weapons
var weapons_node : BoneAttachment
var weapons_node_left : BoneAttachment
var current_weapon_node : MeshInstance
var shooting_node : Spatial
var weapons_count : int

var shooting_time : float = 0.0		# helper for smooth shooting transition
const shooting_anim_blend_time = 0.25

# Grenades
var grenade_manager : Node
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
	if (player != null):
		return
	player = p
	animation_tree.set("parameters/OneShot_Spawn/active", true)
	
func player_spawned():
	print("player_spawned")
	set_physics_process(true)
	start_processing()
	player.connect("player_change_weapon", self, "change_weapon")
	player.connect("player_throw_grenade", self, "control_throw_grenade")
	alive = true
	can_move = true
	
func set_grenade_manager(gm : Node) -> void:
	grenade_manager = gm

func _physics_process(delta):
	if health_points <= 0.0:
		health_points = 0.0
		alive = false
		animation_tree.set("parameters/OneShot_Death/active", true)
	if not alive:
		return
	var front_vec : Vector3 = get_global_transform().basis.z.normalized()
	var direction : Vector3 = Vector3.ZERO
	if can_move:
		direction = handle_movement(front_vec, delta)
	
	if player.shoot and ((front_vec.dot(-direction) < 0) or (direction.length_squared() < 0.05)):
		shooting_time += delta
		animation_tree.set("parameters/Blend2_1/blend_amount", smoothstep(0.0, shooting_anim_blend_time, shooting_time))
#		shooting_node.shoot(get_barrel_position(), current_weapon_node.name)
	else:
		shooting_time = 0.0
		animation_tree.set("parameters/Blend2_1/blend_amount", 0.0)
	
	var walk_blend_value : float = min(velocity.length(), 1.0)
	walk_blend_value *= walk_blend_value
	walk_blend_value *= sign(direction.normalized().dot(front_vec))
	animation_tree.set("parameters/Blend3_1/blend_amount", walk_blend_value)
	animation_tree.set("parameters/Blend2_3/blend_amount", walk_blend_value)
	
	var sprint_blend_value : float = range_lerp(velocity.length(), WALK_SPEED, RUN_SPEED, 0.0, 1.0)
	animation_tree.set("parameters/Blend2_2/blend_amount", sprint_blend_value)

func handle_movement(front_vec : Vector3, delta : float) -> Vector3:
	var direction = Vector3(player.walk_direction.x, 0.0, player.walk_direction.y).normalized()
	var max_speed = RUN_SPEED if (player.sprint and (abs(front_vec.dot(direction) - 1.0) < 0.2)) else WALK_SPEED
	
	var hv = Vector3(velocity.x, 0, velocity.z)
	var new_pos : Vector3 = direction * max_speed
	var acceleration = ACCELERATION if direction.dot(velocity) > 0 else DE_ACCELERATION
	
	hv = hv.linear_interpolate(new_pos, acceleration * delta)
	velocity.x = hv.x
	velocity.y += GRAVITY * delta
	velocity.z = hv.z
	velocity = move_and_slide(velocity, VECTOR_UP)
	return direction

func update_rotation_from_mouse_position():
	if player and alive:
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

func trigger_shot() -> void:
	if shooting_time >= shooting_anim_blend_time:
		shooting_node.shoot(get_barrel_position(), current_weapon_node.name)

func pick_up_grenade():
	var new_grenade : RigidBody = Grenade.instance()
	new_grenade.add_collision_exception_with(self)
	new_grenade.set_mode(RigidBody.MODE_KINEMATIC)
	$"Rotation_Helper/Model/Skeleton/BA_RightHand".add_child(new_grenade, true)
	current_nade = new_grenade
	
func control_throw_grenade() -> void:
	animation_tree.set("parameters/OneShot_Grenade/active", true)
	$RadioSoundPlayer.stream = throw_grenade_sound
	$RadioSoundPlayer.play()
	
func throw_grenade():
	var gm = grenade_manager
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
		
func recoil_from_explosion(recoil_force : Vector3) -> void:
	velocity += recoil_force
	
func get_hit(damage : float) -> void:
	if alive:
		health_points -= damage
		if health_points > 0:
			$HurtSoundPlayer.play()
		else:
			$DeathSoundPlayer.play()
		emit_signal("player_health_changed", self, health_points)
	
func lock_movement() -> void:
	can_move = false
	
func unlock_movement() -> void:
	can_move = true
		
func stop_processing() -> void:
	$Rotation_Helper/Model/AnimationTree.set("parameters/TimeScale/scale", 0.0)
	$PlayerBody_CS.disabled = true
	$PlayerFeet_CS.disabled = true
	
func start_processing() -> void:
	$Rotation_Helper/Model/AnimationTree.set("parameters/TimeScale/scale", 1.0)
	$PlayerBody_CS.disabled = false
	$PlayerFeet_CS.disabled = false
	
# UI specific

func get_player_name() -> String:
	return player_name
	
func set_player_name(p_name : String) -> void:
	player_name = p_name
	
func get_current_weapon_name() -> String:
	return current_weapon_node.name