extends Spatial


var mouse_move_y
var mouse_move_x
var sway_threshold = 5
var sway_lerp = 5
var final_sway : Vector3

export var sway_up : Vector3
export var sway_down : Vector3
export var sway_left : Vector3
export var sway_right : Vector3
export var sway_normal : Vector3



func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		mouse_move_x = -event.relative.x
		mouse_move_y = -event.relative.y

#func _process(delta):
	#if mouse_move != null:
	#	if mouse_move > sway_threshold:
	#		rotation = rotation.linear_interpolate(sway_left, sway_lerp * delta)
	#	elif mouse_move < -sway_threshold:
	#		rotation = rotation.linear_interpolate(sway_right, sway_lerp * delta)
	#	else:
	#		rotation = rotation.linear_interpolate(sway_normal, sway_lerp * delta)

#func _process(delta):
	
#	if mouse_move_y != null:
#		if mouse_move_y > sway_threshold:
#			final_sway += sway_up
#		if mouse_move_y < -sway_threshold:
#			final_sway += sway_down
#	if mouse_move_x != null:
#		if mouse_move_x > sway_threshold:
#			final_sway += sway_left
#		elif mouse_move_x < -sway_threshold:
#			final_sway += sway_right
#	rotation = rotation.linear_interpolate(final_sway, sway_lerp * delta)
