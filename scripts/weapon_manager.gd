extends Node

# - General Weapons
var weapon_id = 01 # weapon id = primary by default

# - Glock
var glock_can_shoot = true


# - onready vars
onready var raycast = get_node("/root/RayCast") # - Player Raycast
onready var ui_anim = get_node("/root/animPlayer") # - UI Animation Player
onready var bullet_decal = preload("res://scripts/bullet_decal.tscn") # - Get Bullet Decal file
onready var blood_splatter = preload("res://scripts/decals/blood_splatter.tscn") # - Get Blood Splatter file
const SURFACE_DIRECTION_UP = Vector3(0, 1, 0) # - Correct bullet decal's direction
const SURFACE_DIRECTION_DOWN = Vector3(0, -1, 0) # -Correct bullet decal's direction

func _ready():
	pass

func glockShotTimer_timeout():
	glock_can_shoot = true


func _process(delta):
# - Weapon ID's
	if Input.is_action_just_pressed("weapon_primary"):
		weapon_id == 01
	if Input.is_action_just_pressed("weapon_secondary"):
		weapon_id == 02

	if weapon_id == 01:
		$AK.show()
		$Glock.hide()
	if weapon_id == 02:
		$Glock.show()
		$AK.hide()
	
	fire_glock()

func spawn_bullet_decal():
	var b = bullet_decal.instance()
	if raycast.is_colliding():
		var target = raycast.get_collider()
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

func spawn_blood_splatter():
	var blsp = blood_splatter.instance()
	if raycast.is_colliding():
		var target = raycast.get_collider()
		target.get_parent().add_child(blsp)
		blsp.global_transform.origin = raycast.get_collision_point()

func fire_glock():
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
				spawn_blood_splatter()
			# - Calculate dmg
				ui_anim.play("hitmarker")
				target.health -= dmg
			spawn_bullet_decal()

	if Input.is_action_just_pressed("reload") and weaponid == 02:
		var glock_ammo_needed = glock_size - glockAmmo
		if glockReserve > glock_ammo_needed:
			glockAmmo = glock_size
			glockReserve -= glock_ammo_needed
			$Glock/Reload.play()
			player_anim.play("glockReload")
		elif glockReserve != 0:
			glockAmmo += glockReserve
			glockReserve = 0
			$Glock/Reload.play()
			player_anim.play("glockReload")
