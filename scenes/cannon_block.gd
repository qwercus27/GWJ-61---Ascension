extends Node

@export var bullet_scene: PackedScene
var speed = 100
var direction
var offScreen
var scale

# Called when the node enters the scene tree for the first time.
func _ready():
	offScreen = true
	scale = Vector2(1, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_scale(scale_v2):
	scale = scale_v2
	$Block.scale = scale_v2
	$VisibleOnScreenNotifier2D.scale = scale_v2


func _on_visible_on_screen_notifier_2d_screen_entered():
	offScreen = false
	$BulletTimer.start()


func _on_bullet_timer_timeout():
	
	var bullet = bullet_scene.instantiate()

	if $Block.position.x < 240:
		direction = 1
		bullet.set_direction("right")
	else: 
		direction = -1
		bullet.set_direction("left")
	
	bullet.position = $Block.position + Vector2(16 * direction, 0)
	bullet.scale = $Block.scale
	#bullet.linear_velocity = Vector2(speed * direction, 0)
	add_child(bullet)


func _on_visible_on_screen_notifier_2d_screen_exited():
	
	offScreen = true
	$BulletTimer.stop()
