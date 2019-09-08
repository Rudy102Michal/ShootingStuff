extends Node

const Player = preload("res://scripts/player/player.gd")

var player: Player;

func handleInput(event: InputEvent):
	if player == null:
		return
	if not player.readiness and event.is_action_pressed("ui_accept"):
		player.readiness = true
	elif (event.is_action_pressed("move_sprint")):
		player.sprint = true
	elif (event.is_action_released("move_sprint")):
		player.sprint = false
	elif (event.is_action_pressed("shoot_primary")):
		player.shoot = true
	elif (event.is_action_released("shoot_primary")):
		player.shoot = false
	if (event.is_action_pressed("shoot_secondary")):
		player.grenade = true
	elif (event.is_action_released("shoot_secondary")):
		player.grenade = false
		return
