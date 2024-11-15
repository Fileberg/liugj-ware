class_name PlayerController
extends Node2D


var input_left : String
var input_right : String
var input_up : String
var input_down : String
var input_action : String
var input_jump : String



func set_input_names(id):
	input_left = "p" + str(id) + "_left"
	input_right = "p" + str(id) + "_right"
	input_up = "p" + str(id) + "_up"
	input_down = "p" + str(id) + "_down"
	input_action = "p" + str(id) + "_action"
	input_jump = "p" + str(id) + "_jump"
