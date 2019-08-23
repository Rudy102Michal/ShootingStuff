extends Node

const Player = preload("res://scripts/player.gd")

var player: Player;

func handleInput(event: InputEvent):
	if player == null:
		return
	if not player.readiness and event.is_action_pressed("ui_accept"):
		player.readiness = true
		return
		
		
	pass
