extends Control

var player_A : PlayerCharacter
var player_B : PlayerCharacter
var player_A_UI
var player_B_UI

# Called when the node enters the scene tree for the first time.
func _ready():
	player_A = null
	player_B = null
	player_A_UI = null
	player_B_UI = null
	$PlayerTopLeft.visible = false
	$PlayerTopRight.visible = false

func register_player(player : PlayerCharacter) -> bool:
	var result : bool = false
	
	var ui_node = get_free_ui_node()
	
	if ui_node != null:
		if player_A == null:
			player_A = player
			enable_player_UI(player_A, ui_node)
			player_A_UI = ui_node
			connect_to_player_signals(player_A)
			result = true
		elif player_B == null:
			player_B = player
			enable_player_UI(player_B, ui_node)
			player_B_UI = ui_node
			connect_to_player_signals(player_B)
			result = true
	
	return result
	
func unregister_player(player : PlayerCharacter) -> void:
	if player_A == player:
		player_A = null
		player_A_UI.visible = false
		player_A_UI = null
	if player_B == player:
		player_B = null
		player_B_UI.visible = false
		player_B_UI = null

func get_free_ui_node() -> CanvasItem:
	for n in get_children():
		if n.visible == false:
			return n as CanvasItem;
	return null
	
func get_player_UI_node(player : PlayerCharacter) -> CanvasItem:
	var ui_node = null
	if player == player_A:
		ui_node = player_A_UI
	elif player == player_B:
		ui_node = player_B_UI
	return ui_node

func enable_player_UI(player : PlayerCharacter, ui_node : CanvasItem):
	ui_node.visible = true
	var label : Label = ui_node.find_node("PlayerNameLabel")
	if label != null:
		label.text = player.get_player_name()
	label = ui_node.find_node("WeaponName")
	if label != null:
		label.text = player.get_current_weapon_name()
	set_health_points(ui_node, 1.0)		# full hp, can be redone later
	
func connect_to_player_signals(player : PlayerCharacter) -> void:
	player.connect("player_health_changed", self, "player_hp_changed")
	player.connect("player_weapon_changed", self, "player_switched_weapon")

func player_hp_changed(player : PlayerCharacter, current_health : float) -> void:
	var ui_node = get_player_UI_node(player)
	if ui_node != null:
		set_health_points(ui_node, current_health)
	
func player_switched_weapon(player : PlayerCharacter, weapon_name : String) -> void:
	var ui_node = get_player_UI_node(player)
	if ui_node != null:
		var weapon_label : Label = ui_node.find_node("WeaponName")
		if weapon_label != null:
			weapon_label.text = weapon_name
	
func set_health_points(ui_node : CanvasItem, hp : float) -> void:
	var hp_bar = ui_node.find_node("HealthBar")
	if hp_bar != null:
		hp_bar.set_progress_value(hp)