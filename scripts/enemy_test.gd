extends KinematicBody

enum {
	IDLE,
	CHASE,
	AIM,
	SHOOT,
	STUN,
	DEAD
}

var health = 100
var is_alive = true
var path = []
var path_node = 0
var speed = 3.5
var dmg = 5
var can_shoot = true
const turn_speed = 3

onready var nav = get_parent()
onready var player = $"../../Player"
onready var target = player
onready var vision_cast = $eyes/VisionCast
onready var shoot_cast = $eyes/ShootCast
onready var animplayer = $SWAT/AnimationPlayer
onready var eyes = $eyes
onready var skeleton = $SWAT/RootNode/CharacterArmature/Skeleton

var state = IDLE

func _ready():
	animplayer.play("CharacterArmature|Idle")
	pass

func _process(delta):
	match state:
		IDLE:
			animplayer.play("CharacterArmature|Idle")
			#Console.write_line("Enemy state: IDLE")

		CHASE:
			animplayer.play("CharacterArmature|Walk")

		AIM:
			animplayer.play("CharacterArmature|Idle_Gun_Pointing")

		SHOOT:
			target.health -= dmg
			animplayer.play("CharacterArmature|Idle_Gun_Shoot")
			can_shoot = false

		STUN:
			animplayer.play("CharacterArmature|HitRecieve_2")

		DEAD:
			pass


	if is_alive:
		self.look_at(target.global_transform.origin, Vector3.UP)
		#rotate_y(deg2rad(self.rotation.y * turn_speed))
	if health <= 0 and is_alive:
		is_alive = false
		animplayer.play("CharacterArmature|Death")
		$modelTimer.start()
		$CollisionShape.queue_free()
		state = DEAD

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

func modelTimer_timeout():
	queue_free()
