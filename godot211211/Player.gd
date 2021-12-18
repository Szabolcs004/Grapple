extends KinematicBody

var velocity = Vector3()
var dir = Vector3()
var fall = Vector3()

var movementspeed = 10
var acceleration = 60
var jumpForce = 12
var sens = 0.2
const gravity = 9.8

onready var head = $Head

onready var grappleCast = $Head/Grappling/FirePoint/Firecast
onready var legbunker = $LegBunker
onready var headbunker = $HeadBunker

onready var line = $ImmediateGeometry

var grappling = false
var hookPoint = Vector3()
var getHookPoint = false
var grappedMovement = 0.05



func moving(delta):
	dir = Vector3.ZERO
	move_and_slide(fall,Vector3.UP)
	
	if not is_on_floor():
		fall.y -= gravity*delta
	if Input.is_action_just_pressed("JUMP") and is_on_floor():
			fall.y += jumpForce
			
	if Input.is_action_pressed("FORWARD"):
		dir += transform.basis.z
	if Input.is_action_pressed("BACKWARD"):
		dir -= transform.basis.z
	if Input.is_action_pressed("LEFTWARD"):
		dir += transform.basis.x
	if Input.is_action_pressed("RIGHTWARD"):
		dir -= transform.basis.x
		
	dir = dir.normalized();
	velocity = velocity.linear_interpolate(dir*movementspeed, acceleration*delta)
	velocity = move_and_slide(velocity,Vector3.UP)



func grapple():
	line.clear()
	
	
	if Input.is_action_just_pressed("RELEASE"):
		grappling = false
		hookPoint = null
		getHookPoint = false
		line.clear()
	
	if Input.is_action_just_pressed("GRAPPLE"):
		if grappleCast.is_colliding():
			print("grapple")
			if not grappling:
				grappling = true
	
	if grappling:
		line.begin(Mesh.PRIMITIVE_LINES)
		
		fall.y = 0
		if not getHookPoint:
			hookPoint = grappleCast.get_collision_point()
			getHookPoint = true
		
		line.set_color(Color.red)
		line.add_vertex(grappleCast.transform.origin)
		line.add_vertex(to_local(hookPoint))
		
		line.end()
		
		if hookPoint.distance_to(transform.origin) > 2:
			if getHookPoint:
				transform.origin = lerp(transform.origin, hookPoint, grappedMovement)
		else:
			grappling = false
			getHookPoint = false
	
	if headbunker.is_colliding() or legbunker.is_colliding():
		grappling = false
		hookPoint = null
		getHookPoint = false



func _unhandled_input(event):
	if event is InputEventMouseMotion: #and cam_is_rotating:
		rotate_y(deg2rad(-event.relative.x * sens))
		head.rotate_x(deg2rad(event.relative.y * sens))
		head.rotation.x = clamp(head.rotation.x,deg2rad(-90),deg2rad(90))
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()



func _physics_process(delta):
	#if switch_grappling_to_weapon:
	#	fire_something(bullet)
	#else:
	grapple()
	moving(delta)
	#wall_running()



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
