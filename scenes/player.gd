extends RigidBody2D

var screen_size
@export var upSpeed =7
var downSpeed = 4
var horSpeed = 3
var staticBodyCollision
var canAscend
var ascendTimeout

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	screen_size = get_viewport_rect().size
	staticBodyCollision = false
	ascendTimeout = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#if ascendTimeout or Input.is_action_pressed("ascend") == false: 
	#		(move_and_collide(Vector2(0,1) * downSpeed))
	
	if Input.is_action_just_pressed("ascend") and ascendTimeout:
		$AscendTimer.start(0.5)
		set_linear_velocity(Vector2(0,0))
		ascendTimeout = false
		apply_central_force(Vector2(0,-25000))
	
	#if Input.is_action_pressed("ascend"):
#		if(ascendTimeout == false): move_and_collide(Vector2(0,-1) * upSpeed)
		
	if Input.is_action_pressed("move_right"):
		#move_and_collide(Vector2(1,0) * horSpeed)
		apply_central_force(Vector2(500, 0))
	if Input.is_action_pressed("move_left"):
		#move_and_collide(Vector2(-1,0) * horSpeed)
		apply_central_force(Vector2(-500, 0))
	
	
func start(pos):
	
	# reset the player when starting a new game.
	
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_ascend_timer_timeout():
	ascendTimeout = true
