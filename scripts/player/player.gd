extends KinematicBody

export var health = 100
var curr_max_health = 100
export var dmg = 25
var speed = 5.1
var walk_speed = 2.5
var crouch_speed = 1.5
var tocrouch_speed = 12
var default_height = 1.15
var crouch_height = 0.55
var crouching = false
const ACCEL_DEFAULT = 24
const ACCEL_AIR = 6
onready var accel = ACCEL_DEFAULT
var gravity = 24
var jump = 6.5
var cam_accel = 40
var mouse_sens = 0.15
var snap
var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()


onready var pcap = $CollisionShape
onready var head = $Head
onready var camera = $Head/Camera
onready var gunCam = $Head/Camera/ViewportContainer/Viewport/GunCam
onready var raycast = $Head/Camera/RayCast
onready var ui_anim = $playerUI/uiAnim
onready var player_anim = $animPlayer
onready var healthLabel = $playerUI/Health

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# - Health Command
	Console.add_command('set_health', self, 'health')\
		.set_description('set player health')\
		.add_argument('health', TYPE_INT)\
		.register()
# - Kill Command
	Console.add_command('kill', self, 'respawn')\
		.set_description('commit suicide')\
		.register()
# - Sensitivity Command
	Console.add_command('sensitivity', self, 'mouse_sens')\
		.set_description('set mouse sensitivity [default: 0.15]')\
		.add_argument('mouse_sens', Console.FloatRangeType.new(0, 1, 0.05))\
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


func _process(delta):
	if health <= 0:
		respawn()
	if health != curr_max_health:
		ui_anim.play("pain")
		curr_max_health = health
	healthLabel.set_text(String(health))

	if Console.is_console_shown:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# - Camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	gunCam.global_transform = camera.global_transform
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform


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
	if Input.is_action_just_released("jump") and is_on_floor():
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
		else:
			velocity = velocity.linear_interpolate(direction * speed, accel * delta)
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
			health -= int(round(gravity_vec.length() * 4.25))
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
