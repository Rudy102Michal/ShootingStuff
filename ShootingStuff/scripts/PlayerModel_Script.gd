extends Spatial

var right_hand : BoneAttachment
var left_hand : BoneAttachment
var base_gtf : Transform

# Called when the node enters the scene tree for the first time.
func _ready():
	right_hand = $Skeleton/BA_RightHand
	left_hand = $Skeleton/BA_LeftHand
	base_gtf = find_node("Weapon", true, false).get_global_transform()
	
func attach_weapon_to_left_hand() -> void:
	var Weapon : Spatial = find_node("Weapon", true, false)
	var WeaponLH : Spatial = find_node("WeaponLeftHand", true, false)
	var p = Weapon.find_parent("*")
	#var gtf : Transform = Weapon.get_global_transform()
	base_gtf = Weapon.get_global_transform()
	#p.remove_child(Weapon)
	#left_hand.add_child(Weapon, true)
	Weapon.set_visible(false)
	WeaponLH.set_visible(true)
	#Weapon.set_global_transform(gtf)
	#Weapon.global_transform = base_gtf
	#Weapon.orthonormalize()
	print("Weapon to left")
	
func attach_weapon_to_right_hand() -> void:
	var Weapon : Spatial = find_node("Weapon", true, false)
	var WeaponLH : Spatial = find_node("WeaponLeftHand", true, false)
	var p = Weapon.find_parent("*")
	#var gtf : Transform = Weapon.get_global_transform()
	#p.remove_child(Weapon)
	#right_hand.add_child(Weapon, true)
	Weapon.set_visible(true)
	WeaponLH.set_visible(false)
	#Weapon.set_global_transform(gtf)
	#Weapon.global_transform = base_gtf
	#Weapon.orthonormalize()
	print("WEapon to right")

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	print(old_name + " --> " + new_name)


func _on_AnimationPlayer_animation_started(anim_name):
	print(anim_name)
