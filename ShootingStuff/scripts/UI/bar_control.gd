extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_progress_value(value : float) -> void:
	value = min(1.0, max(0.0, value)) 		# cap it to [0.0, 1.0]
	$Progress.value = $Progress.min_value + int(value * float($Progress.max_value - $Progress.min_value))