extends MarginContainer

export(bool) var menu_visible setget set_menu_visible
export(bool) var invitation_visible = true setget set_invitation_visible

var all_ready = false
var menu_container: Container
var selected_option = 0

func set_menu_visible(visible):
	menu_visible = visible
	menu_container.visible = visible
	
func set_invitation_visible(visible):
	invitation_visible = visible
	find_node("Invitation").visible = visible
	
func set_selected_option(option):
	menu_container.get_child(selected_option).add_color_override("font_color", Color(255,255,255))
	menu_container.get_child(option).add_color_override("font_color", Color(255,255,0))
	selected_option = option
	
func _on_player_joined():
	set_menu_visible(global.players.size() > 0)
	set_invitation_visible(global.players.size() < global.PLAYER_NAMES.size())
	
func _on_player_left():
	set_menu_visible(global.players.size() > 0)
	set_invitation_visible(true)
	
func _ready():
	menu_container = find_node("Menu")
	set_selected_option(0)
	menu_container.visible = menu_visible
	find_node("Invitation").visible = invitation_visible
	find_node("Loading").visible = false
	find_node("Ready").visible = false
	global.connect("player_joined", self, "_on_player_joined")
	global.connect("controller_disconnected", self, "_on_player_left")
	
func _input(event):
	if menu_visible:
		if (event.is_action_pressed("ui_up")):
			set_selected_option(menu_container.get_child_count() - 1 if selected_option == 0 else selected_option - 1)
		elif (event.is_action_pressed("ui_down")):
			set_selected_option(0 if selected_option == menu_container.get_child_count() - 1 else selected_option + 1)
		elif (event.is_action_pressed("ui_accept")):
			if (selected_option == 1):
				get_tree().quit()
			else:
				set_menu_visible(false)
				find_node("Ready").visible = true
		pass
	if all_ready and event.is_action_pressed("ui_accept"):
		menu_container.visible = false
		find_node("Invitation").visible = false
		find_node("Loading").visible = true
		find_node("Ready").visible = false
		
		yield( get_tree().create_timer(0.01), "timeout" )
		start_game()
		pass

	var are_all_ready = global.players.size() > 0
	var cam = get_tree().get_root().get_camera()
	for player in global.players:
		var pos = player.player_node.get_translation()
		pos.y += 10
		var screenPos = cam.unproject_position(pos)
		
		var readiness_node = player.player_node.find_node("Ready")
		readiness_node.set_position(screenPos)
		readiness_node.visible = player.readiness
		if not player.readiness:
			are_all_ready = false
	if are_all_ready:
		all_ready = true

func start_game():
	get_tree().change_scene("scenes/playground.tscn")