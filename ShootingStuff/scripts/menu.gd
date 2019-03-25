extends Node2D

export(bool) var menu_visible setget set_menu_visible
export(bool) var invitation_visible = true setget set_invitation_visible

var started = false
var timeout = 0.0

func set_menu_visible(visible):
	menu_visible = visible
	$Menu.visible = visible
	timeout = 0.1
	
func set_invitation_visible(visible):
	invitation_visible = visible
	$Invitation.visible = visible

func _ready():
	$Menu.visible = menu_visible
	$Invitation.visible = invitation_visible
	$Loading.visible = false
	
func _process(delta):
	if timeout > 0:
		timeout -= delta
	elif started:
		get_tree().change_scene("scenes/playground.tscn")
	
func _input(event):
	if (event.is_action("ui_accept") && menu_visible && timeout <= 0):
		$Menu.visible = false
		$Invitation.visible = false
		$Loading.visible = true
		started = true
		timeout = 0.1