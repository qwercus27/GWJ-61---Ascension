extends CharacterBody2D

signal hit
signal healed
const SPEED = 300.0
var max_jump_vel
var min_jump_vel
var jump_vel
var canAscend
var gravity = 400
var maxHP = 3
var HP
var on_floor
var on_wall
var gameOver
var inHitState
var ascending
var centered
var friction
var goalCrossed
var playerScale

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	playerScale = Vector2(1, 1)
	canAscend = true
	ascending = false
	set_max_jump_vel()
	set_min_jump_vel()
	jump_vel = max_jump_vel
	HP = maxHP
	on_floor = false
	on_wall = false
	gameOver = false
	inHitState = false
	centered = true
	friction = 30
	goalCrossed = false


func set_max_jump_vel():
	max_jump_vel = -300 - (scale.x * 64)


func set_min_jump_vel():
	min_jump_vel = -250 + (scale.x * 64)


func _physics_process(delta):
	
	if inHitState:
		canAscend = false
	
	if ascending :
		position.y = move_toward(position.y, position.y - 10, SPEED)
		velocity.y = 0
			
	if velocity.y > 600 :
		velocity.y = 600
	
	if on_floor: 
		jump_vel = max_jump_vel
		$JumpSound.pitch_scale = 1
		friction = 100
		$JumpSound.volume_db = -7.781
	else: 
		if not ascending: 
			velocity.y += gravity * delta
		friction = 10
	
	# Handle Jump.
	if Input.is_action_just_pressed("ascend") and canAscend:
		
		$AscendTimer.start(0.4)
		
		if jump_vel < 0 and not goalCrossed: 
			$JumpSound.play()
			
		if jump_vel < min_jump_vel: 
			velocity.y = jump_vel
		else: 
			jump_vel = 0
			
		jump_vel = jump_vel * 0.9
		canAscend = false
		$JumpSound.pitch_scale += 0.1
		$JumpSound.volume_db -= 0.2


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction and not on_wall and not gameOver:
		velocity.x = move_toward(velocity.x, direction * 200, 30)
		#friction = move_toward(friction, 1, 3)
		
	else:
		#friction = move_toward(friction, 15, 1)
		velocity.x = move_toward(velocity.x, 0, friction)
	
	if velocity.x != 0: 
		centered = false
		$DirectionTimer.paused = true
	elif velocity.x == 0: 
		$DirectionTimer.paused = false
		if $DirectionTimer.time_left == 0 and centered == false:
			$DirectionTimer.start(2.0)
	
	if velocity.y < 10 and velocity.y > -10:
		if velocity.x > 0: 
			$Sprite2D.animation = "center_right"
		elif velocity.x < 0: 
			$Sprite2D.animation = "center_left"
		elif velocity.x == 0 and centered: 
			$Sprite2D.animation = "center_center"
	elif velocity.y > 10:
		if velocity.x > 0: 
			$Sprite2D.animation = "down_right"
		elif velocity.x < 0: 
			$Sprite2D.animation = "down_left"
		elif velocity.x == 0 and centered: 
			$Sprite2D.animation = "down_center"
	elif velocity.y < -10:
		if velocity.x > 0: 
			$Sprite2D.animation = "up_right"
		elif velocity.x < 0: 
			$Sprite2D.animation = "up_left"
		elif velocity.x == 0 and centered: 
			$Sprite2D.animation = "up_center"
		
	# COLLISION
	var collision = move_and_collide(velocity * delta)
	
	if collision: 
		
		velocity = velocity.slide(collision.get_normal())
		var collider = collision.get_collider()
		var colName = collider.get("name")
		var colClass = collider.get_class()
		var nodeName = collider.get_meta("node_name")
		
		if nodeName == "block":
			var colPos = collision.get_position()
			if colPos.y > position.y + 15: 
				on_floor = true
			if colPos.x > position.x + 15 or colPos.x < position.x - 15: 
				on_wall = true
			
		if nodeName == "bullet" and not inHitState: 
			collider.queue_free()
			hit.emit()
			velocity.y = 0
		
		if nodeName == "heart_item":
			if HP < 3: 
				HP += 1
			collider.queue_free()
	else: # if !collision
		on_floor = false
		on_wall = false
	
	if position.x > (480 - 16): 
		position.x = 480 - 16
	if position.x < 16: 
		position.x = 16


func disable_collision():
	$CollisionShape2D.disabled = true


func game_over():
	gameOver = true


func set_ascending(boolValue):
	ascending = boolValue


func set_player_scale(scale_num):
	scale = scale_num
	playerScale = scale_num
	set_max_jump_vel()
	set_min_jump_vel()


func _on_area_2d_area_entered(area):

	if area.get_meta("node_name") == "heart_item":
		$HeartSound.play()
		if HP < 3: 
			HP += 1 
			healed.emit()
		area.queue_free()
		
	elif area.get_meta("node_name") == "goal": 
		goalCrossed = true


func _on_ascend_timer_timeout():
	canAscend = true


func _on_direction_timer_timeout():
	centered = true
	$DirectionTimer.stop()

func _on_hit():
	inHitState = true
	$HitSound.play()
	$HitTimer.start()
	$VisibleTimer.start()
	hide()


func _on_hit_timer_timeout():
	inHitState = false
	$VisibleTimer.stop()
	show()


func _on_visible_timer_timeout():
	if is_visible():
		hide()
	else:
		show()









