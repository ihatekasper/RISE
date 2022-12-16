extends Spatial

onready var door_anim = $door_anim
onready var waitTimer = $waitTimer
onready var exitTimer = $exitTimer
onready var pcolblock = $playerblocker/playercollisionblocker
onready var door_snd = $snd_door_move

func front_area_entered(body):
	if body.is_in_group("Player"):
		waitTimer.start()

func exit_area_entered(body):
	if body.is_in_group("Player"):
		door_snd.play()
		exitTimer.start()
		door_anim.play("close")
		$exitArea.queue_free()

func waitTimer_timeout():
	door_anim.play("open")
	door_snd.play()

func exitTimer_timeout():
	pcolblock.queue_free()
