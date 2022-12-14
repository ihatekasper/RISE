extends KinematicBody


export var health = 100
var curr_max_health = 100
onready var healthLabel = $playerUI/Health
export var dmg = 25
var speed = 5.1
var walk_speed = 2.5
var crouch_speed = 1.5
var tocrouch_speed = 12
var default_height = 1.15
var crouch_height = 0.55
const ACCEL_DEFAULT = 24
const ACCEL_AIR = 6
const SURFACE_DIRECTION_UP = Vector3(0, 1, 0)
const SURFACE_DIRECTION_DOWN = Vector3(0, -1, 0)
onready var accel = ACCEL_DEFAULT
var gravity = 24
var jump = 6.5
var cam_accel = 40
var mouse_sens = 0.04
var snap
var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

enum GROUND_STATE {
	GROUNDED,
	MIDAIR,
	TOUCHDOWN
}

var player_state = GROUND_STATE.GROUNDED
onready var pcap = $CollisionShape
onready var head = $Head
onready var camera = $Head/Camera
onready var gunCam = $Head/Camera/ViewportContainer/Viewport/GunCam
onready var raycast = $Head/Camera/RayCast
onready var ui_anim = $playerUI/uiAnim
onready var player_anim = $animPlayer

onready var glockLight = $Head/Hand/Weapons/Glock/Muzzlelight
onready var glockFlash = $Head/Hand/Weapons/Glock/MuzzleFlash
onready var glockTimer = $Timers/glockShotTimer

onready var bullet_decal = preload("res://scripts/bullet_decal.tscn")
onready var blood_splatter = preload("res://scripts/decals/blood_splatter.tscn")

# - Weapons
export var glockAmmo = 15
export var glockReserve = 30
onready var glock_size = glockAmmo
export var akAmmo = 30
export var akReserve = 60

onready var ammoLabel = $playerUI/Ammo

var weaponid = 01

var glock_can_shoot = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	glockTimer.start()
	akTimer.start()
	$Head/Hand/Weapons/AK.show()
	$Head/Hand/Weapons/Glock.hide()

# - Health Console Command
	Console.add_command('set_health', self, 'health')\
		.set_description('set player health')\
		.add_argument('health', TYPE_INT)\
		.register()

	Console.add_command('kill', self, 'respawn')\
		.set_description('commit suicide')\
		.register()



func _input(event):
# - Get mouse input for camera rotation
	if event is InputEventMouseMotion and not Console.is_console_shown:
		rotate_y(deg2rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

# - Respawn on death
func respawn():
	self.translation = Vector3(0, 23, 0)
	head.rotation = Vector3(0, 0, 0)
	health = 100

# - Handle Glock Firing
func glockShotTimer_timeout():
	#glockLight.hide()
	glock_can_shoot = true

func fireGlock():
	if Input.is_action_just_pressed("fire") and glock_can_shoot and not Console.is_console_shown and weaponid == 02 and glockAmmo > 0:
		glock_can_shoot = false
		glockLight.show()
		glockFlash.show()
		glockTimer.start()
		player_anim.play("glockFire")
		$Head/Hand/Weapons/Glock/Fire.pitch_scale = rand_range(0.95, 1.05)
		$Head/Hand/Weapons/Glock/Fire.play()
		glockAmmo -= 1

	# - Do damage
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target.is_in_group("Enemy"):
			# - Blood splatter
				var blsp = blood_splatter.instance()
				target.get_parent().add_child(blsp)
				blsp.global_transform.origin = raycast.get_collision_point()
			# - Calculate dmg
				ui_anim.play("hitmarker")
				target.health -= dmg
				Console.write_line("hp = " + String(target.health))
				Console.write_line("hitboxes = " + String(target.get_name()))
				#if target.is_in_group("Head"):
				#	pass

	# - Bullet decals
			var b = bullet_decal.instance()
			if raycast.get_collider() != null and not target.is_in_group("Enemy"):
				raycast.get_collider().add_child(b)
				b.global_transform.origin = raycast.get_collision_point()
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)

			if raycast.get_collision_normal() == SURFACE_DIRECTION_UP:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)

			elif raycast.get_collision_normal() == SURFACE_DIRECTION_DOWN:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)

			else:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)

	if Input.is_action_just_pressed("reload") and weaponid == 02 and glockAmmo != glock_size:
		var glock_ammo_needed = glock_size - glockAmmo
		if glockReserve > glock_ammo_needed:
			glockAmmo = glock_size
			glockReserve -= glock_ammo_needed
			$Head/Hand/Weapons/Glock/Reload.play()
			player_anim.play("glockReload")
			Console.write_line("MAKE GLOCK RELOAD NOT INSTANT FR")
		elif glockReserve != 0:
			glockAmmo += glockReserve
			glockReserve = 0
			$Head/Hand/Weapons/Glock/Reload.play()


var ak_can_shoot = true
onready var akLight = $Head/Hand/Weapons/AK/Muzzlelight
onready var akFlash = $Head/Hand/Weapons/AK/MuzzleFlash2
onready var akTimer = $Timers/akShotTimer

func akShotTimer_timeout():
	ak_can_shoot = true

func fireAk():
	if Input.is_action_pressed("fire") and ak_can_shoot and not Console.is_console_shown and weaponid == 01:
		ak_can_shoot = false
		akLight.show()
		akFlash.show()
		akTimer.start()
		player_anim.play("akFire")
		$Head/Hand/Weapons/Glock/Fire.pitch_scale = rand_range(0.95, 1.05)
		$Head/Hand/Weapons/Glock/Fire.play()

	# - Do damage
		if raycast.is_colliding():
			var target = raycast.get_collider()
			if target.is_in_group("Enemy"):
			# - Blood splatter
				var blsp = blood_splatter.instance()
				target.get_parent().add_child(blsp)
				blsp.global_transform.origin = raycast.get_collision_point()
			# - Calculate dmg
				ui_anim.play("hitmarker")
				target.health -= dmg / 1.5
				Console.write_line("hp = " + String(target.health))
				Console.write_line("hitboxes = " + String(target.get_name()))
				#if target.is_in_group("Head"):
				#	pass

	# - Bullet decals
			var b = bullet_decal.instance()
			if raycast.get_collider() != null and not target.is_in_group("Enemy"):
				raycast.get_collider().add_child(b)
				b.global_transform.origin = raycast.get_collision_point()
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)

			if raycast.get_collision_normal() == SURFACE_DIRECTION_UP:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)

			elif raycast.get_collision_normal() == SURFACE_DIRECTION_DOWN:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)

			else:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)



func _process(delta):
	if health <= 0:
		respawn()
	
	if health != curr_max_health:
		ui_anim.play("pain")
		curr_max_health = health
	
	
	fireAk()
	fireGlock()
	
	healthLabel.set_text("+ " + String(health))
	if weaponid == 01:
		ammoLabel.set_text("// " + String(akAmmo) + "/" + String(akReserve))
	if weaponid == 02:
		ammoLabel.set_text("// " + String(glockAmmo) + "/" + String(glockReserve))
	
	gunCam.global_transform = camera.global_transform

	if Console.is_console_shown:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# - Camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform

	if Input.is_action_just_pressed("weapon_primary"):
		$Head/Hand/Weapons/AK.show()
		$Head/Hand/Weapons/Glock.hide()
		weaponid = 01
	if Input.is_action_just_pressed("weapon_secondary"):
		$Head/Hand/Weapons/AK.hide()
		$Head/Hand/Weapons/Glock.show()
		weaponid = 02


var crouching = false

func _physics_process(delta):
	# - Get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var h_input = Input.get_action_strength("straferight") - Input.get_action_strength("strafeleft")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	
	# - Jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	elif is_on_ceiling() and not is_on_floor():
		snap = Vector3.DOWN
		gravity_vec += Vector3.DOWN * gravity * 6 * delta
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	
	# - Make it move
	if Input.get_action_strength("walk") and is_on_floor():
		velocity = velocity.linear_interpolate(direction * walk_speed, accel * delta)
		movement = velocity + gravity_vec
	elif Input.is_action_pressed("crouch"):
		crouching = true
		pcap.shape.height -= tocrouch_speed * delta
		if is_on_floor():
			velocity = velocity.linear_interpolate(direction * crouch_speed, accel * delta)
		movement = velocity + gravity_vec
	elif $CollisionShape/CeilCheck.is_colliding() and crouching:
		pcap.shape.height -= tocrouch_speed * delta
		velocity = velocity.linear_interpolate(direction * crouch_speed, accel * delta)
		movement = velocity + gravity_vec
	else:
		crouching = false
		pcap.shape.height += tocrouch_speed * delta
		velocity = velocity.linear_interpolate(direction * speed, accel * delta)
		movement = velocity + gravity_vec
	pcap.shape.height = clamp(pcap.shape.height, crouch_height, default_height)

	move_and_slide_with_snap(movement, snap, Vector3.UP)
	
	# - Fall damage
	if is_on_floor():
		if gravity_vec.length() >= 20:
			health -= int(round(gravity_vec.length() * 2.25))
			$Audio/sndImpact.play()
		elif gravity_vec.length() >= 2:
			$Audio/sndRun.pitch_scale = rand_range(0.8, 1.2)
			$Audio/sndRun.play()

	# - do audio!
	if $Timers/sndRunTimer.time_left <= 0:
		if direction != Vector3.ZERO and is_on_floor():
			$Audio/sndRun.pitch_scale = rand_range(0.8, 1.2)
			$Audio/sndRun.play()
			$Timers/sndRunTimer.start(0.4)
