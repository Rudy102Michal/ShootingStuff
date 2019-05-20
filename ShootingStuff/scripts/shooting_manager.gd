extends Spatial

var XCOM_BULLET = preload("res://prefabs/bullets/BulletXCOM.tscn")
const XCOM_BULLET_FIRERATE = 5.0
var xcom_can_shoot : bool = true;

var shoot_timer : Timer

onready var enemy_manager = $"../Enemies"

func _ready():
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 1.0 / XCOM_BULLET_FIRERATE
	shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
	add_child(shoot_timer)
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
	pass
	
func shoot_shotgun(barrel_node : Position3D):
	print("shotgun shot")
	# TODO
	
	pass
	
func handle_hit(enemy : Object):
	enemy.kill_yourself()
	pass
	
func _on_shoot_timer_timeout():
	xcom_can_shoot = true
	shoot_timer.stop()
	pass