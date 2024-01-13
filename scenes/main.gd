extends Node

@export var block_scene: PackedScene
@export var cannon_scene: PackedScene
@export var goal_scene: PackedScene
@export var heart_item_scene: PackedScene

var scaleNum = 1.5
var scale = Vector2(scaleNum, scaleNum)
var blockSize = 32 * scaleNum
var maxRow
var firstRowY
var ySpacing
var levelNumber
var gameOver
var goalReached

# Called when the node enters the scene tree for the first time.
func _ready():

	levelNumber = 1
	$HUD.update_hearts($Player.HP, $Player.maxHP)
	new_game()


func new_game():

	goalReached = false
	
	maxRow = 2 + ((levelNumber-1))
	firstRowY = blockSize * 3
	ySpacing = blockSize * 10
	
	$HUD.hide_message()
	$HUD.show_level(levelNumber)
	
	$Block.position.y = (firstRowY + ySpacing)
	$Block.scale = scale
	
	$Player.set_ascending(false)
	$Player.set_player_scale(scale)
	$Player.goalCrossed = false
	$Player.on_floor = true
	$Player.z_index = 1
	$Player.position = $Block.position - Vector2(0, blockSize*2)
	
	spawnFloor()
	spawnBlocks()
	spawnCannons()
	setGoal()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("escape"):
		if not get_tree().paused: 
			get_tree().paused = true
			$HUD.show_message("paused", 36)
		else: 
			get_tree().paused = false
			$HUD/Message.hide()
		
	if not gameOver and not goalReached: 
		$Camera.position.y = $Player.position.y
		$ColorRect.position.y = $Player.position.y - $ColorRect.size.y/2
		


func spawnFloor():
	var posArray = []
	
	for i in 480/blockSize:
		posArray.append(Vector2((i * blockSize) + blockSize/2, (firstRowY + ySpacing*2)))
	for v2 in posArray:
		var block = block_scene.instantiate()
		block.position = v2
		block.scale = scale
		block.add_to_group("generated")
		add_child(block)


func spawnCannons():
	
	var posArray = []
	var maxCannons = maxRow + 1
	
	for i in maxCannons:
		
		var offset = firstRowY + ((ySpacing/10)*5) # = 96 + 160 = 256
		var tempY = offset - (ySpacing * i)
		var isRight = randi() % 2
		var tempX = 0
		
		if isRight: 
			tempX = 480 - blockSize/2
		
		var tempPos = Vector2(tempX, tempY).snapped(Vector2(blockSize, blockSize))
		posArray.append(tempPos)
	
	for v2 in posArray:

		var cannon = cannon_scene.instantiate()
		cannon.set_scale(scale)
		cannon.get_child(0).position = v2
		cannon.get_child(1).position = v2
		
		add_child(cannon)


func spawnBlocks():

	var posArray = []
	
	for i in maxRow:

		var tempY = firstRowY - (ySpacing * i)
		var count = randi_range(1, 3)
		
		for c in count:
			var width = randi_range(1, 3)
			var tempX = randi_range(480/blockSize, 480-blockSize)
			
			for n in width:
			
				var tempPos = Vector2(tempX + n * blockSize, tempY).snapped(Vector2(blockSize,blockSize))
				tempPos.x -= blockSize/2
				if tempPos.x > 480-(blockSize/2):
					tempPos.x = 480-(blockSize/2)
				if posArray.find(tempPos) == -1:
					posArray.append(tempPos)
	
	var heartBlock = randi_range(0, posArray.size()-1)
	
	for v2 in posArray:
		var block =  block_scene.instantiate()
		block.position = v2
		block.scale = scale
		block.add_to_group("generated")
		add_child(block)
		
		if posArray.find(v2) == heartBlock:
			var heartItem = heart_item_scene.instantiate()
			heartItem.position = v2 + Vector2(0, -blockSize)
			heartItem.scale = scale
			if heartItem.position.x > 480-blockSize:
				heartItem.position.x = 480-blockSize
			heartItem.add_to_group("generated")
			add_child(heartItem)


func setGoal():
	
	$Goal.position.y = firstRowY - (ySpacing * (maxRow))
	$Goal.scale = scale  


func _on_goal_crossed():
	$ClearSound.play()
	$HUD.show_message("SUCCESS!", 64)
	goalReached = true
	$Player.set_ascending(true)
	await get_tree().create_timer(3.0).timeout
	levelNumber += 1
	get_tree().call_group("cannons", "queue_free")
	get_tree().call_group("generated", "queue_free")
	new_game()


func game_over():
	gameOver = true
	$Player.game_over()
	$Player.disable_collision()
	await get_tree().create_timer(2.0).timeout
	$HUD.show_message("Game Over :(", 64)
	#$Label.position = $Camera.position - Vector2($Label.get_minimum_size().x/2, 0)
	#$Label.show()
	await await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")


func _on_player_body_hit():
	$Player.HP -= 1
	if $Player.HP < 0:
		$Player.HP = 0
	$HUD.update_hearts($Player.HP, $Player.maxHP)
	if $Player.HP == 0:
		game_over()


func _on_player_healed():
	$HUD.update_hearts($Player.HP, $Player.maxHP)
