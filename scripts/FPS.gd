extends RichTextLabel

func _ready():
		# Registering command
	# 1. argument is command name
	# 2. arg. is target (target could be a funcref)
	# 3. arg. is target name (name is not required if it is the same as first arg or target is a funcref)

	self.hide()
	Console.add_command('ui_showfps', self, 'showfps')\
		.set_description('displays frames per second')\
		.add_argument('boolean', TYPE_BOOL)\
		.register()

func showfps(boolean):
	if boolean == true:
		Console.write_line('showfps = true')
		self.show()
	if boolean == false:
		Console.write_line('showfps = false')
		self.hide()

func _process(delta: float) -> void:
	set_text(String(Engine.get_frames_per_second()) + " fps")
