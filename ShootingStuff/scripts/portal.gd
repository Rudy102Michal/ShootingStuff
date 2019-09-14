extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Portal Entry")

func _entry_over():
	$AnimationPlayer.play("Portal Idle")