extends Spatial

var pickup = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass



func area_entered(body):
	if body.is_in_group("Player"):
		pickup = true
