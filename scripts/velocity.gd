extends RichTextLabel

onready var player = get_parent().get_parent()

func _ready():
	self.hide()
	Console.add_command('ui_showvel', self, 'showvelocity')\
		.set_description('displays velocity')\
		.add_argument('boolean', TYPE_BOOL)\
		.register()

func showvelocity(boolean):
	if boolean == true:
		self.show()
	if boolean == false:
		self.hide()

func _process(delta: float) -> void:
	set_text("vel: " + String(player.velocity.length()))
