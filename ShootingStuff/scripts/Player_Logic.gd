extends KinematicBody

# Signals

# Constants
const GRAVITY : Vector3 = Vector3(0.0, -9.8, 0.0)
var MAX_SPEED : float = 4.0
const ACCELERATION : float  = 3.0
const DE_ACCELERATION : float = 7.0
#const ANGLE_STEP : int = 90
const JUMP_SPEED : float = 3.5
const FLOOR_NORMAL : Vector3 = Vector3(0, 1.0, 0.0)

# Controls
var control_node : Node = null
var animation_tree : AnimationTree

# Weapons variables
var weapons_node : BoneAttachment
var current_weapon_node : MeshInstance
var shooting_node : Spatial
var weapons_count : int

# Movement
var velocity : Vector3
var old_velocity : Vector3

func _ready():
	velocity = Vector3(0.0, 0.0, 0.0)
	old_velocity = velocity
	animation_tree = $Rotation_Helper/Model/AnimationTree
	weapons_node = $Rotation_Helper/Model/Skeleton/BoneAttachment
	for weapon in weapons_node.get_children():
		weapon.visible = false
	current_weapon_node = weapons_node.get_children()[0] # starting weapon is xcom_rifle
	current_weapon_node.visible = true
	weapons_count = weapons_node.get_child_count()
	shooting_node = $"../../Bullets"
	
func _physics_process(delta):
	handle_player_movement(delta)
	
func handle_player_movement(delta):
	if control_node == null:
		return
		
	var front_vec : Vector3 = get_global_transform().basis.z
	var left_vec : Vector3 = FLOOR_NORMAL.cross(front_vec)
	var direction : Vector3 = Vector3(0.0, 0.0, 0.0)
	
	if control_node.should_start_sprint():
		MAX_SPEED = 8.0
	if control_node.should_stop_sprint():
		MAX_SPEED = 4.0
	
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
	
#	if old_velocity.length() < 0.08 and velocity.length() > 0.08:
#		var asm : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
#		asm.travel("Gun_Walk")
#	elif old_velocity.length() > 0.08 and velocity.length() < 0.08:
#		var asm : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
#		asm.travel("Gun_Stand_Idle")
	
	if control_node.is_shooting():
		animation_tree.set("parameters/Blend2_1/blend_amount", 1.0)
		shooting_node.shoot(get_barrel_position(), current_weapon_node.name)
	else:
		animation_tree.set("parameters/Blend2_1/blend_amount", 0.0)
		
	if control_node.should_change_weapon():
		change_weapon()
	
	var walk_blend_value : float = min(velocity.length(), 1.0)
	walk_blend_value *= walk_blend_value
	walk_blend_value *= sign(direction.normalized().dot(front_vec))
	animation_tree.set("parameters/Blend3_1/blend_amount", walk_blend_value)
	animation_tree.set("parameters/Blend2_3/blend_amount", walk_blend_value)
	
	var sprint_blend_value : float = min(1.0, max(0, velocity.length() - 4.0))
	animation_tree.set("parameters/Blend2_2/blend_amount", sprint_blend_value)
	
	if control_node.should_throw_grenade():
		animation_tree.set("parameters/OneShot_Grenade/active", true)
	
#	print(walk_blend_value)
#	old_velocity = velocity

func attach_control_node(node : Node) -> void:
	add_child(node)
	control_node = node
	control_node.attach_player_node(self)
	# Other stuff to trigger, maybe
	
func change_weapon() -> void:
	for index in range(weapons_count):
		if weapons_node.get_children()[index].visible:
			weapons_node.get_children()[index].visible = false
			if index + 1 == weapons_count: # Last weapon, cycle back to 1
				current_weapon_node = weapons_node.get_children()[0] as MeshInstance
				current_weapon_node.visible = true
			else: 
				current_weapon_node = weapons_node.get_children()[index + 1] as MeshInstance
				current_weapon_node.visible = true
			return

func get_barrel_position() -> Position3D:
	return current_weapon_node.get_node("./BarrelPosition") as Position3D