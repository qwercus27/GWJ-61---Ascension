extends StaticBody2D

var speed
var direction
var dirInt

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 100
	#direction = "right"
	dirInt = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if direction == "left": dirInt = -1
	
	position.x += speed * dirInt * delta
	#linear_velocity = Vector2(100, 0)
	
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	
	queue_free()
	

func _on_body_entered(body):
	if(body.get("name")) == "PlayerBody": queue_free()
		

func set_speed(sp):
	speed = sp
	
func set_direction(dir):
	direction = dir
