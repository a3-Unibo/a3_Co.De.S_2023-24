extends CharacterBody3D

@onready var camera_mount = $"camera mount"
@onready var step_ray = $StepRay
@onready var camera_3rd_person = $"camera mount/Camera3rdPerson"
@onready var camera_1st_person = $"camera mount/Camera1stPerson"

var initial_position
const minRotFirst : float = -89.0 # look down
const maxRotFirst : float = 89.0 # look up
const minRot3rd : float = -65.0 # look down
const maxRot3rd : float = 45.0 # look up
var minRot : float
var maxRot : float

var lerp_speed = 10.0
var direction = Vector3.ZERO

@export var speed = 3.0
@export var run_speed = 6.0
@export var sprint_speed = 10.0
@export var jump_speed = 4.5
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5
@export var step_height = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# hide mouse arrow
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# record initial position for respawn
	initial_position = position
	camera_3rd_person.current = true
	camera_1st_person.current = false
	minRot = minRot3rd
	maxRot = maxRot3rd
	
func _input(event):
	if event is InputEventMouseMotion:
		var h_ang : float = deg_to_rad(-event.relative.x * sens_horizontal)
		var v_ang : float = deg_to_rad(-event.relative.y * sens_vertical)
		rotate_y(h_ang)
		camera_mount.rotate_x(v_ang)
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(minRot), deg_to_rad(maxRot))
	# Handle respawn
	if Input.is_action_just_pressed("respawn"):
		transform.origin = initial_position
	# Handle quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	# Handle camera switch
	if Input.is_action_just_pressed("camera_switch"):
		if(camera_3rd_person.current):
			camera_3rd_person.clear_current()
			camera_1st_person.make_current()
			minRot = minRotFirst
			maxRot = maxRotFirst
		else:
			camera_1st_person.clear_current()
			camera_3rd_person.make_current()
			minRot = minRot3rd
			maxRot = maxRot3rd
	# Handle screenshots
	if Input.is_action_just_pressed("screenshot"):
		screenshot()
	# Toggle mouse visibility
	if Input.is_action_just_pressed("mouseToggle"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction and handle the movement/deceleration.
	var actual_speed = speed
	if Input.is_action_pressed("run"):
		actual_speed = run_speed
	if Input.is_action_pressed("sprint"):
		actual_speed = sprint_speed
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * actual_speed
		velocity.z = direction.z * actual_speed
	else:
		velocity.x = move_toward(velocity.x, 0, actual_speed)
		velocity.z = move_toward(velocity.z, 0, actual_speed)
		
	handle_stairs()

	move_and_slide()
	#var collision = move_and_collide(velocity)
	#if collision:
	#	velocity = velocity.slide(collision.get_normal())
		#velocity *= SPEED

func handle_stairs():
	if step_ray.is_colliding():
		var colliison_point = step_ray.get_collision_point()
		var height = colliison_point.y - global_position.y
		if height <= step_height:
			global_position.y = colliison_point.y


# This is a function for capturing screenshots with GDScript
# from: https://gist.github.com/jotson/84681c2064653d093083a690e9fa5998
# Adapted for Godot4.2.1 by Alessio Erioli
func screenshot():
	# Capture the screenshot
	var image = get_viewport().get_texture().get_image()
		
	# Setup path and screenshot filename
	var date = Time.get_datetime_dict_from_system()
	var path = OS.get_executable_path().get_base_dir().path_join("screenshots")
	#var path = "user://screenshots"
	var file_name = "screenshot_%d%02d%02d_%02d.%02d.%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
	print(file_name)
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)
	var dir = DirAccess.open(path)
	
	# Find a filename that isn't taken
	var n = 1
	var file_path = path.path_join(file_name) + ".png"
	while(true):
		if dir.file_exists(file_path):
			file_path = path.path_join(file_name) + "-" + str(n) + ".png"
			n = n + 1
		else:
			break
	print("Screenshot saved in ", ProjectSettings.globalize_path(path))
	
	# Save the screenshot
	image.save_png(file_path)
