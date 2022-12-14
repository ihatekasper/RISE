extends KinematicBody


func _ready():
	$SWAT/RootNode/CharacterArmature/Skeleton.physical_bones_start_simulation()
	print("do ragdoll bro.")
