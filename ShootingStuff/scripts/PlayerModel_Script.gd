extends Spatial

var right_hand : BoneAttachment
var left_hand : BoneAttachment

# Called when the node enters the scene tree for the first time.
func _ready():
	right_hand = $Skeleton/BA_RightHand
	left_hand = $Skeleton/BA_LeftHand
	
func attach_weapon_to_left_hand() -> void:
	var Weapon : Node = find_node("Weapon", true, false)
	var p = Weapon.find_parent("*")
	p.remove_child(Weapon)
	left_hand.add_child(Weapon, true)
	
func attach_weapon_to_right_hand() -> void:
	var Weapon : Node = find_node("Weapon", true, false)
	var p = Weapon.find_parent("*")
	p.remove_child(Weapon)
	right_hand.add_child(Weapon, true)