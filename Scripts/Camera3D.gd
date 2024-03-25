extends Camera3D

@onready var target = $"../Player/Truck/truck_grey/CamTarget"

@export var follow_speed = 100.0
@export var offset_y = Vector3.ZERO
@export var offset_z = Vector3.ZERO
@export var lerp_speed = 2
@export var cam_logging = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !target:
		return
	var target_pos = target.global_transform.translated_local(offset_y + -offset_z)
	global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	look_at(target.global_position, Vector3.UP)
	print_logs()

func print_logs():
	if cam_logging:
		print("Cam position: ", global_position)
