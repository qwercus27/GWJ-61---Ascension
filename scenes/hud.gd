extends CanvasLayer

@export var heart_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func update_hearts(HP, maxHP):
	
	var counter = 1
	
	for point in maxHP:
		var heart =  heart_scene.instantiate()
		heart.position = Vector2(32 + (point * 36), 32)
		if((point + 1) > HP):
			heart.animation = "empty"
		add_child(heart)


func show_message(message, font_size):
	$Message.text = message
	$Message.label_settings.set_font_size(font_size)
	$Message.show()


func hide_message():
	$Message.hide()


func show_level(levelNumber):
	$LevelMessage.text = "Level " + str(levelNumber)
	if(levelNumber == 1): 
		$LevelMessage.text = "Level " + str(levelNumber) + "\n" + "Press space to jump"
	$LevelMessage.show()
	await get_tree().create_timer(5.0).timeout
	$LevelMessage.hide()
	
