extends KinematicBody

export var health = 100
var curr_max_health = 100
var path = []
var path_node = 0
var speed = 3.5
var dmg = 3
var can_shoot = true
var can_talk = true
var target
const turn_speed = 3

onready var player = $"../../Player"
onready var vision_cast = $VisionCast
onready var shoot_cast = $ShootCast
onready var animplayer = $SWAT/AnimationPlayer
onready var eyes = $eyes
onready var skeleton = $SWAT/RootNode/CharacterArmature/Skeleton

# - Dialogue
onready var good_morning01 = $Dialogue/good_morning01

func _ready():
	animplayer.play("CharacterArmature|Idle")
	#Console.write_line("Enemy state: IDLE")

func _process(delta):
	if health != curr_max_health:
		if animplayer.is_playing() == true:
			animplayer.stop()
			animplayer.play("CharacterArmature|HitRecieve_2")
		else:
			animplayer.play("CharacterArmature|HitRecieve_2")
		curr_max_health = health
		$shotTimer.stop()
		$stunTimer.start()


func _physics_process(delta):
	pass


func dialogue_area_body_entered(body):
	if body.is_in_group("Player") and can_talk == true:
		good_morning01.play()
		can_talk = false
		$Dialogue/diaWait.start()


func diaWait_timeout():
	can_talk = true
