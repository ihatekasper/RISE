extends KinematicBody

enum {
	IDLE,
	CHASE,
	AIM,
	SHOOT,
	DEAD
}

export var health = 100
var curr_max_health = 100
var is_alive = true
var path = []
var path_node = 0
var speed = 3.5
var dmg = 3
var can_shoot = true
var anim_played = false
const turn_speed = 3

onready var nav = get_parent()
onready var player = $"../../Player"
onready var target = player
onready var vision_cast = $VisionCast
onready var shoot_cast = $ShootCast
onready var animplayer = $SWAT/AnimationPlayer
onready var eyes = $eyes
onready var skeleton = $SWAT/RootNode/CharacterArmature/Skeleton

var state = IDLE

func _ready():
	state = IDLE
	pass

func _process(delta):
	if health != curr_max_health:
		animplayer.play("CharacterArmature|HitRecieve_2")
		curr_max_health = health
		$shotTimer.stop()
		$stunTimer.start()
		Console.write_line("STUNNED")
	
	match state:
		IDLE:
			animplayer.play("CharacterArmature|Idle")
			#Console.write_line("Enemy state: IDLE")

		CHASE:
			animplayer.play("CharacterArmature|Walk")

		AIM:
			pass

		SHOOT:
			target.health -= dmg
			if anim_played == false:
				$Audio/Fire.pitch_scale = rand_range(0.8, 1.2)
				$Audio/Fire.play()
				animplayer.play("CharacterArmature|Idle_Gun_Shoot")
				anim_played = true
			can_shoot = false

		DEAD:
			pass


	if is_alive:
		eyes.look_at(target.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * turn_speed))
	if health <= 0 and is_alive:
		is_alive = false
		animplayer.play("CharacterArmature|Death")
		$modelTimer.start()
		$CollisionShape.queue_free()
		state = DEAD
		
	if $walkSndTimer.time_left <= 0:
		if state == CHASE:
			$Audio/Walk.pitch_scale = rand_range(0.8, 1.2)
			$Audio/Walk.play()
			$walkSndTimer.start(0.4)


func _physics_process(delta):

	if vision_cast.is_colliding() and is_alive:
		if vision_cast.get_collider() == target and not shoot_cast.is_colliding():
			state = CHASE
		elif shoot_cast.is_colliding() and shoot_cast.get_collider() == target and is_alive:
			if not can_shoot:
				state = AIM
			if can_shoot:
				state = SHOOT
		else:
			state = IDLE
	
	if path_node < path.size() and is_alive and state == CHASE:
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		elif is_alive:
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func move_to(target_pos):
	if is_alive:
		path = nav.get_simple_path(global_transform.origin, target_pos)
		path_node = 0

func timerTimeout():
	if is_alive:
		move_to(player.global_transform.origin)

func shotTimer_timeout():
	can_shoot = true
	anim_played = false

func modelTimer_timeout():
	queue_free()

func stunTimer_timeout():
	$shotTimer.start()
