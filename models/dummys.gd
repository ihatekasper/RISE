extends Spatial

var health = 100



func _ready():
	pass

func _process(delta):
	if health <= 0:
		queue_free()
