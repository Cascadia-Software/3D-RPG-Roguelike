extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var MouseInput : bool = false
var Pitch : float
var Yaw : float
var MouseRot : Vector3
var PlayerRotation : Vector3
var CameraRotation : Vector3
@export var PitchMax := deg_to_rad(90)
@export var PitchMin := deg_to_rad(-90)
@export var Camera_Controller : Camera3D
@export var MouseSensitivity : float = 0.5

func _unhandled_input(event):
	MouseInput = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if MouseInput:
		Yaw = -event.relative.x * MouseSensitivity
		Pitch = -event.relative.y * MouseSensitivity


func UpdateCameraRot(delta):
	MouseRot.x += Pitch * delta
	MouseRot.x = clamp(MouseRot.x, PitchMin, PitchMax)
	MouseRot.y += Yaw * delta
	
	PlayerRotation = Vector3(0.0,MouseRot.y,0.0)
	CameraRotation = Vector3(MouseRot.x,0.0,0.0)
	
	Camera_Controller.transform.basis = Basis.from_euler(CameraRotation)
	global_transform.basis = Basis.from_euler(PlayerRotation)
	MouseRot.z = 0.0
	Pitch = 0.0
	Yaw = 0.0
	
	
func _ready(): 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # hides mouse and locks position to center of screen


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	UpdateCameraRot(delta)
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
