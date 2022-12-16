extends Spatial


# ----------------------- General
var weapon_id
var dmg
const SURFACE_DIRECTION_UP = Vector3(0, 1, 0)
const SURFACE_DIRECTION_DOWN = Vector3(0, -1, 0)

# ----------------------- Animations & Decals
onready var player = get_parent().get_parent().get_parent()
onready var player_anim = player.get_node("animPlayer")
onready var ui_anim = player.get_node("playerUI/uiAnim")
onready var ammoLabel = player.get_node("playerUI/Ammo")
onready var raycast = player.get_node("Head/Camera/RayCast")
onready var bullet_decal = preload("res://weapons/bullet_decal.tscn")
onready var blood_splatter = preload("res://scripts/decals/blood_splatter.tscn")

# ----------------------- Glock
var glock_can_shoot = true
export var glockAmmo = 15
export var glockReserve = 60
onready var weapon_glock = $Glock
onready var glock_size = glockAmmo
onready var glockLight = $Glock/Muzzlelight
onready var glockFlash = $Glock/MuzzleFlash
onready var glockTimer = $Glock/glockShotTimer

# ----------------------- AK47
var ak_can_shoot = true
export var akAmmo = 30
export var akReserve = 60
onready var weapon_ak = $AK
onready var ak_size = glockAmmo
onready var akLight = $AK/Muzzlelight
onready var akFlash = $AK/MuzzleFlash
onready var akTimer = $AK/akShotTimer

func _ready():
	weapon_id = 00
	glockTimer.connect("timeout", self, "glockShotTimer_timeout")
	glockTimer.start()
	akTimer.connect("timeout", self, "akShotTimer_timeout")
	akTimer.start()

func _process(delta):
	weapon_switch()
	handle_ui()
	fireGlock()
	fireAk()
	if weapon_id == 00:
		weapon_ak.hide()
		weapon_glock.hide()
	if weapon_id == 01:
		weapon_ak.show()
		weapon_glock.hide()
		dmg = 20
	if weapon_id == 02:
		weapon_ak.hide()
		weapon_glock.show()
		dmg = 15

func weapon_switch():
	if Input.is_action_just_pressed("weapon_primary"):
		weapon_id = 01
	if Input.is_action_just_pressed("weapon_secondary"):
		weapon_id = 02
	if Input.is_action_just_pressed("weapon_melee"):
		weapon_id = 00

func handle_ui():
	if weapon_id == 01:
		ammoLabel.show()
		ammoLabel.set_text(String(akAmmo) + " | " + String(akReserve))
	if weapon_id == 02:
		ammoLabel.show()
		ammoLabel.set_text(String(glockAmmo) + " | " + String(glockReserve))
	if weapon_id == 00:
		ammoLabel.hide()

func glockShotTimer_timeout():
	glock_can_shoot = true
func fireGlock():
	if Input.is_action_just_pressed("fire") and glock_can_shoot and not Console.is_console_shown and weapon_id == 02 and glockAmmo > 0:
		glock_can_shoot = false
		glockLight.show()
		glockFlash.show()
		glockTimer.start()
		player_anim.play("glockFire")
		$Glock/Fire.pitch_scale = rand_range(0.95, 1.05)
		$Glock/Fire.play()
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

	if Input.is_action_just_pressed("reload") and weapon_id == 02 and glockAmmo != glock_size:
		var glock_ammo_needed = glock_size - glockAmmo
		if glockReserve > glock_ammo_needed:
			glockAmmo = glock_size
			glockReserve -= glock_ammo_needed
			$Glock/Reload.play()
			player_anim.play("glockReload")
			Console.write_line("MAKE GLOCK RELOAD NOT INSTANT BTW")
		elif glockReserve != 0:
			glockAmmo += glockReserve
			glockReserve = 0
			$Glock/Reload.play()
			player_anim.play("glockReload")

func akShotTimer_timeout():
	ak_can_shoot = true
func fireAk():
	if Input.is_action_pressed("fire") and ak_can_shoot and not Console.is_console_shown and weapon_id == 01:
		ak_can_shoot = false
		akLight.show()
		akFlash.show()
		akTimer.start()
		player_anim.play("akFire")
		$AK/Fire.pitch_scale = rand_range(0.95, 1.05)
		$AK/Fire.play()

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
