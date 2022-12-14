extends Spatial

onready var dTimer = $decalTimer
onready var eTimer = $emitTimer
onready var decal = $MeshInstance
onready var emitter = $emitter


func _ready():
	dTimer.start()
	eTimer.start()

func decalTimer_timeout():
	decal.queue_free()
	dTimer.stop()

func emitTimer_timeout():
	emitter.queue_free()
	eTimer.stop()
