extends Spatial

# Base file for managing (spawning etc... ) enemies
const DEMOGORGON = preload("res://models/demogorgon/demogorgon.tscn")
onready var players_container = get_node("../Players")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# TODO: this is temporary - it spawns one enemy at (0,0,0)
	# this will be handled in some loop with proper logic
	
	var d = DEMOGORGON.instance()
	d.set_players_container(players_container)
	add_child(d)
	
	pass