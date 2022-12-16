extends Control

var current_version = 0.2

# > Screens
onready var mainScr = $mainScr
onready var playScr = $playScr
onready var optionsScr = $optionsScr



func _ready():
	add_res_items()
	update_activity()
	mainScr.show()
	playScr.hide()
	optionsScr.hide()
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	$HTTPRequest.request("https://raw.githubusercontent.com/ihatekasper/rise/main/version.txt")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	$mainScr/CurrentVersion.set_text("Current Version: v" + String(json.result))
	if json.result != current_version:
		$mainScr/updateText.show()
		$mainScr/updateBtn.show()
	else:
		$mainScr/updateText.hide()
		$mainScr/updateBtn.hide()

func _process(delta):
	devtestingBtn_hovered()
	facilityBtn_hovered()

func updateBtn_pressed():
	OS.shell_open("https://github.com/ihatekasper/RISE/releases")

# > Main Screen Buttons

func playBtn_pressed():
	mainScr.hide()
	playScr.show()
	optionsScr.hide()

func optionsBtn_pressed():
	mainScr.hide()
	optionsScr.show()

func exitBtn_pressed():
	get_tree().quit()



# > Play Screen Buttons

onready var createSub = $playScr/createSub
onready var mapsSub = $playScr/mapsSub

# Play Tabs

func pbackTab_pressed():
	playScr.hide()
	mainScr.show()
	mapsSub.hide()
	createSub.show()

func createTab_pressed():
	createSub.show()
	mapsSub.hide()

func mapBtn_pressed():
	createSub.hide()
	mapsSub.show()

func devtestingBtn_pressed():
	queue_free()
	get_tree().change_scene("res://map/dev_testing.tscn")

func facilityBtn_pressed():
	queue_free()
	get_tree().change_scene("res://map/blackmesa/lobby.tscn")

func arcadeBtn_pressed():
	queue_free()
	get_tree().change_scene("res://map/dm_arcade.tscn")

func powerplantBtn_pressed():
	queue_free()
	get_tree().change_scene("res://map/de_powerplant.tscn")

func devtestingBtn_hovered():
	if $playScr/mapsSub/devtestingBtn.is_hovered():
		$playScr/dev_testingBG.show()
	else:
		$playScr/dev_testingBG.hide()

func facilityBtn_hovered():
	if $playScr/mapsSub/facilityBtn.is_hovered():
		$playScr/facilityBG.show()
	else:
		$playScr/facilityBG.hide()

# > Options Screen Buttons

onready var resolutionBox = $optionsScr/videoOptions/resolutionBox

onready var generalOptions = $optionsScr/generalOptions
onready var videoOptions = $optionsScr/videoOptions

onready var generalLabel = $optionsScr/tabLabels/generalLabel
onready var videoLabel = $optionsScr/tabLabels/videoLabel

# Options Tabs
func obackTab_pressed():
	mainScr.show()
	optionsScr.hide()

# Option Buttons

func generalTab_pressed():
	generalLabel.show()
	videoLabel.hide()
	
	generalOptions.show()
	videoOptions.hide()


func videoTab_pressed():
	generalLabel.hide()
	videoLabel.show()
	
	generalOptions.hide()
	videoOptions.show()

func add_res_items():
	resolutionBox.add_item("1920x1080")
	resolutionBox.add_item("1600x900")
	resolutionBox.add_item("1280x720")
	resolutionBox.add_item("1024x768")

func audioTab_pressed():
	pass # Replace with function body.









# - Discord Activity
func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	activity.set_details("in Main Menu")
	activity.set_state("")

	var assets = activity.get_assets()
	assets.set_large_image("gameicondesat")
	assets.set_large_text("RISE")
	assets.set_small_image("")
	assets.set_small_text("")

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(result)
