extends Spatial

var mouseMovementY
var mouseMovementX
var swayThreshold = 4
var swayLerp = 2

onready var player = get_parent().get_parent()

export var swayLeft : Vector3
export var swayRight : Vector3
export var swayUp : Vector3
export var swayDown : Vector3
export var swayNormal : Vector3

func _ready():
	mouseMovementX = 0
	mouseMovementY = 0

func _input(event):
	if event is InputEventMouseMotion and not Console.is_console_shown:
		mouseMovementY = -event.relative.x
		mouseMovementX = event.relative.y

func _process(delta):
	#if player.gravity_vec.length() != null:
	#	rotation = rotation.linear_interpolate(swayUp, player.gravity_vec.length() * 1.5 * swayLerp * delta)
	#elif player.gravity_vec.length() <= 1:
	#	mouseMovementX = 0
	#	mouseMovementY = 0
	
	if mouseMovementY != null or mouseMovementX != null:
		if mouseMovementY > swayThreshold:
			rotation = rotation.linear_interpolate(swayLeft, swayLerp * delta)
			mouseMovementY = 0
		elif mouseMovementY < -swayThreshold:
			rotation = rotation.linear_interpolate(swayRight, swayLerp * delta)
			mouseMovementY = 0
		if mouseMovementX > swayThreshold:
			rotation = rotation.linear_interpolate(swayUp, swayLerp * delta)
			mouseMovementX = 0
		elif mouseMovementX < -swayThreshold:
			rotation = rotation.linear_interpolate(swayDown, swayLerp * delta)
			mouseMovementX = 0
		else:
			rotation = rotation.linear_interpolate(swayNormal, swayLerp * delta)
			mouseMovementX = 0
			mouseMovementY = 0
