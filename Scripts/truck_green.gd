extends RigidBody3D

@export var min_flying_force: float = .1
@export var max_flying_force: float = 1

@export var speed = 2
@export var accel = 10
@onready var target = $"../Player"

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _ready():
	set_physics_process(false)
	call_deferred("_awaitNavmap")

func _awaitNavmap():
	await get_tree().physics_frame
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	
	var direction = Vector3()
	nav.target_position = target.global_position
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	linear_velocity = linear_velocity.lerp(direction * speed, accel * delta)
	
	move_and_collide(linear_velocity)

func _on_body_entered(body):
	if body.is_in_group("player") and body is RigidBody3D:
		print('SMASHED - Signal working')
		var direction = (body.global_transform.origin - -global_transform.origin).normalized()
		var player_speed = body.linear_velocity.length()
		var flying_force = clamp(player_speed, min_flying_force, max_flying_force)
		apply_central_impulse(direction * flying_force)
