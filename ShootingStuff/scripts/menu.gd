extends MarginContainer

export(bool) var menu_visible setget set_menu_visible
export(bool) var invitation_visible = true setget set_invitation_visible

var started = false
var timeout = 0.0

func set_menu_visible(visible):
	menu_visible = visible
	find_node("Menu").visible = visible
	timeout = 0.1
	
func set_invitation_visible(visible):
	invitation_visible = visible
	find_node("Invitation").visible = visible

func _ready():
	find_node("Menu").visible = menu_visible
	find_node("Invitation").visible = invitation_visible
	find_node("Loading").visible = false
	
func _process(delta):
	if timeout > 0:
		timeout -= delta
	elif started:
		get_tree().change_scene("scenes/playground.tscn")
	
func _input(event):
	if (event.is_action("ui_accept") && menu_visible && timeout <= 0):
		find_node("Menu").visible = false
		find_node("Invitation").visible = false
		find_node("Loading").visible = true
		started = true
		timeout = 0.1