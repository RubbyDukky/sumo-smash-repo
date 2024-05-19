class_name State
extends Node

signal transition


func on_process(delta):
	pass


func on_physics_process(delta):
	pass


func enter():
	pass


func exit():
	pass


# inputs

func get_movement_axis():
	return Input.get_axis("move_left", "move_right")


func get_jump_input():
	return Input.is_action_pressed("jump")


func get_jump_input_just_pressed():
	return Input.is_action_just_pressed("jump")


func get_crouch_input():
	return Input.is_action_pressed("down")


func get_bounce_input():
	return Input.is_action_pressed("bounce")
