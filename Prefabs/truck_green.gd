extends RigidBody3D

var min_flying_force: float = 500.0
var max_flying_force: float = 1500.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$".".body_entered.connect(_on_Player_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Player_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body is RigidBody3D:
		print('SMASHED - Signal working')
		var direction = (body.global_transform.origin - global_transform.origin).normalized()
		var player_speed = body.linear_velocity.length()
		var flying_force = clamp(player_speed, min_flying_force, max_flying_force)
		apply_central_impulse(direction * flying_force)
