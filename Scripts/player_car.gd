extends RigidBody3D

# Refs
@onready var car_mesh = $Truck/truck_grey
@onready var ground_ray = $Truck/truck_grey/RayCast3D
@onready var smoke_particles = $Truck/truck_grey/SmokeParticles
@onready var drift_particles = $Truck/truck_grey/DriftParticles

# Where to place the car mesh relative to the sphere
var sphere_offset = Vector3.DOWN
# Engine power
@export var acceleration = 50.0
# Turn amount, in degrees
@export var steering = 18.0
# How quickly the car turns
@export var turn_speed = 4.0
# Below this speed, the car doesn't turn
@export var turn_stop_limit = 0.75
# How much the body of the car tilts on a turn
@export var body_tilt = 12
@export var torque = Vector3(0, 0, 0)

@export var player_logging = false

var min_flying_force: float = 500.0
var max_flying_force: float = 1500.0

#for caching original values
var orig_turn_speed
var orig_acceleration

# Variables for input values
var speed_input = 0
var turn_input = 0

func _ready():
	orig_turn_speed = turn_speed
	orig_acceleration = acceleration
	smoke_particles.emitting = true
	drift_particles.set_visible(false)

# Car mesh following the under-lying sphere
func _physics_process(delta):
	car_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(car_mesh.global_transform.basis.z * speed_input)
		jump(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Forward and backward driving 
	if not ground_ray.is_colliding():
		reset_car_position()
		return
	speed_input = Input.get_axis("player_brake", "player_accelerate") * acceleration
	turn_input = Input.get_axis("steer_right", "steer_left") * deg_to_rad(steering)
	
	# car boosting and drifting 
	if Input.is_action_pressed("boost") and speed_input:
		boost(1, 65)
	elif Input.is_action_pressed("handbrake") and turn_input and speed_input:
		drift(10, 25)
		drift_particles.set_visible(true)
		smoke_particles.emitting = false
	else:
		reset_vars()
		drift_particles.set_visible(false)
		smoke_particles.emitting = true
	print_logs()
	
	# Turning and mesh movement
	if linear_velocity.length() > turn_stop_limit:
		if speed_input > 0:
			var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, turn_input)
			car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
			car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
			
			var t = -turn_input * linear_velocity.length() / body_tilt
			car_mesh.rotation.z = lerp(car_mesh.rotation.z, t, 10 * delta)
		if speed_input < 0:
			var new_basis = car_mesh.global_transform.basis.rotated(-car_mesh.global_transform.basis.y, turn_input)
			car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
			car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
			
			var t = turn_input * linear_velocity.length() / body_tilt
			car_mesh.rotation.z = lerp(car_mesh.rotation.z, t, 10 * delta)
		if ground_ray.is_colliding():
			var n = ground_ray.get_collision_normal()
			var xform = align_with_y(car_mesh.global_transform, n)
			car_mesh.global_transform = car_mesh.global_transform.interpolate_with(xform, 10.0 * delta)

# Used for slopes
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()

# Car speeds up and turns are sharper 
func drift(turn_speed_drift, acceleration_drift):
	# 'shift'
	print("DRIFT")
	torque = Vector3(0, 0, 1.5)
	turn_speed = turn_speed_drift
	acceleration = acceleration_drift
	apply_torque(torque)

func boost(turn_speed_boost, acceleration_boost):
	#'n'
	print("BOOOOOST")
	acceleration = acceleration_boost
	turn_speed = turn_speed_boost

func jump(jump_factor):
	# spacebar
	if Input.is_action_just_pressed("bounce"):
		apply_central_impulse(car_mesh.global_transform.basis.y * jump_factor)
		#apply_central_impulse(car_mesh.global_transform.basis.z * jump_factor)

func reset_vars():
	turn_speed = orig_turn_speed
	acceleration = orig_acceleration

func reset_car_position():
	if Input.is_action_just_pressed("reset_position"):
		#player position
		transform.origin.y = 1
		rotation_degrees = Vector3(0, 0, 0)
		#truck mesh position
		car_mesh.transform.origin.y = 1
		car_mesh.rotation_degrees = Vector3(0, 0, 0)
		print("RESET")

func print_logs():
	if player_logging:
		print("Speed: ", speed_input)
		print("Acceleration: ", acceleration)
		print("Turn Speed: ", turn_speed)
		print("Torque: ", torque)
