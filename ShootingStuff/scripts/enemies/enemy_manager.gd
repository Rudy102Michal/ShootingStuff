extends Spatial

# Base file for managing (spawning etc... ) enemies
const DEMOGORGON = preload("res://prefabs/enemies/demogorgon.tscn")
onready var players_container = get_node("../Players")

var alive_enemies : int setget set_alive_enemies_count

# Called when the node enters the scene tree for the first time.
func _ready():
	alive_enemies = get_child_count()
	pass
	
func set_alive_enemies_count(count):
	alive_enemies = count
	if count == 0:
		$"../../Interface".won()