extends MarginContainer

export(bool) var menu_visible setget set_menu_visible
export(bool) var invitation_visible = true setget set_invitation_visible

func set_menu_visible(visible):
	menu_visible = visible
	find_node("Menu").visible = visible
	
func set_invitation_visible(visible):
	invitation_visible = visible
	find_node("Invitation").visible = visible
	
func _on_player_joined():
	set_menu_visible(global.players.size() > 0)
	set_invitation_visible(global.players.size() < global.PLAYER_NAMES.size())
	
func _on_player_left():
	set_menu_visible(global.players.size() > 0)
	set_invitation_visible(true)
	
func _ready():
	find_node("Menu").visible = menu_visible
	find_node("Invitation").visible = invitation_visible
	find_node("Loading").visible = false
	global.connect("player_joined", self, "_on_player_joined")
	global.connect("controller_disconnected", self, "_on_player_left")
	
func _input(event):
	var all_ready = global.players.size() > 0
	for player in global.players:
		if not player.readiness:
			all_ready = false
			break
	if all_ready:
		find_node("Menu").visible = false
		find_node("Invitation").visible = false
		find_node("Loading").visible = true
		call_deferred("start_game")
		
func start_game():
	get_tree().change_scene("scenes/playground.tscn")