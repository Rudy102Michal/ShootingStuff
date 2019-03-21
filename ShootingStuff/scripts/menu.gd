extends Node2D

export(bool) var menu_visible setget set_menu_visible
export(bool) var invitation_visible = true setget set_invitation_visible

func set_menu_visible(visible):
	$Menu.visible = visible
	
func set_invitation_visible(visible):
	$Invitation.visible = visible

func _ready():
	$Menu.visible = menu_visible
	$Invitation.visible = invitation_visible