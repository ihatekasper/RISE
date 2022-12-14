extends Spatial

onready var intPrompt = $BtnArea/interactPrompt
onready var predummy = preload("res://scripts/dummy.tscn")
onready var dummyspawn = $dummySpawn

var inBtnArea = false

func _ready():
	update_activity()
	intPrompt.hide()

func BtnArea_body_entered(body):
	if body.is_in_group("Player"):
		intPrompt.show()
		inBtnArea = true


func BtnArea_body_exited(body):
	if body.is_in_group("Player"):
		intPrompt.hide()
		inBtnArea = false

func _process(delta):
	if Input.is_action_just_pressed("interact") and inBtnArea:
		Console.write_line("button pressed")
		var dummy = predummy.instance()
		dummyspawn.add_child(dummy)



# - Discord Activity
func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_details("in Development on dev_testing")
	activity.set_state("developer testing")

	var assets = activity.get_assets()
	assets.set_large_image("gameicondesat")
	assets.set_large_text("RISE")
	assets.set_small_image("wrenchicon")
	assets.set_small_text("Developing...")

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(result)
