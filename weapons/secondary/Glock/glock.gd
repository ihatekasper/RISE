extends Spatial

onready var muzzleLight = $Muzzlelight
onready var muzzleFlash = $MuzzleFlash

func _ready():
	muzzleLight.hide()
	muzzleFlash.hide()

func muzzleTimer_timeout():
	muzzleLight.hide()
	muzzleFlash.hide()
