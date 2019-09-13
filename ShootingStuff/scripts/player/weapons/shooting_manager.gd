extends Spatial

const VECTOR_UP : Vector3 = Vector3(0.0, 1.0, 0.0)

var XCOM_BULLET = preload("res://prefabs/bullets/BulletXCOM.tscn")
const XCOM_BULLET_FIRERATE : float = 5.0
var xcom_can_shoot : bool = true;

const SHOTGUN_FIRERATE : float = 1.0
var shotgun_can_shoot : bool = true;
const SHOTGUN_RANGE : float  = 30.0
const SHOTGUN_SPREAD : float = PI / 6.0
const SHOTGUN_PELLET_COUNT : int = 5
const SHOTGUN_DMG : float = 20.0

var shoot_timer : Timer
var shotgun_timer : Timer

onready var enemy_manager = $"../Enemies"

func _ready():
	
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 1.0 / XCOM_BULLET_FIRERATE
	shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
	add_child(shoot_timer)
	
	shotgun_timer = Timer.new()
	shotgun_timer.wait_time = 1.0 / SHOTGUN_FIRERATE
	shotgun_timer.connect("timeout", self, "_on_shotgun_timer_timeout")
	add_child(shotgun_timer)
	pass

func shoot(barrel_node : Position3D, weapon_name : String):
	match weapon_name:
		"XCom_rifle":
			shoot_xcom(barrel_node)
		"shotgun-zx-76":
			shoot_shotgun(barrel_node)
			
	
func shoot_xcom(barrel_node : Position3D):
	if not xcom_can_shoot:
		return
	xcom_can_shoot = false
	shoot_timer.start()
	var muzzle_transform = barrel_node.global_transform
	var muzzle_front_vec : Vector3 = -muzzle_transform.basis.x
	var b = XCOM_BULLET.instance()
	b.global_transform = muzzle_transform
	b.shot_direction = muzzle_front_vec.normalized()
	add_child(b)
	$"XCom-ShootingSound".play()
	pass
	
func shoot_shotgun(barrel_node : Position3D):
	if not shotgun_can_shoot:
		return
	shotgun_can_shoot = false
	shotgun_timer.start()
	
	var muzzle_transform = barrel_node.global_transform
	var muzzle_front_vec : Vector3 = -muzzle_transform.basis.z
	var space_state = get_world().direct_space_state
	for i in range(SHOTGUN_PELLET_COUNT):
		var shot_vector = (muzzle_front_vec * SHOTGUN_RANGE).rotated(VECTOR_UP, rand_range(-SHOTGUN_SPREAD, SHOTGUN_SPREAD))
		var result = space_state.intersect_ray(muzzle_transform.origin, muzzle_transform.origin + shot_vector, [self])
		if result.size() > 0:
			if result.collider != null:
				#print(result.collider.name)
				if result.collider.is_in_group("enemies"):
					handle_hit(result.collider, SHOTGUN_DMG)
	
	var particles_emitters = barrel_node.get_node("../ParticlesEmitters").get_children()
	for emitter in particles_emitters:
		emitter.emitting = true
	$"shotgun-zx-76-ShootingSound2".play()
	pass
	
func handle_hit(enemy : Object, dmg : float):
	enemy.get_hit(dmg)
	pass
	
func _on_shoot_timer_timeout():
	xcom_can_shoot = true
	shoot_timer.stop()
	pass
	
func _on_shotgun_timer_timeout():
	shotgun_can_shoot = true
	shotgun_timer.stop()
	pass