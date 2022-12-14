extends Spatial

onready var eTimer = $emitTimer
onready var emitter = $emitter

func _ready():
	eTimer.start()

func emitTimer_timeout():
	emitter.queue_free()
	eTimer.stop()
