extends Camera3D

@onready var target = $"../Player"

@export var follow_speed = 100.0
@export var offset = Vector3(0, 1.5, -3)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var target_position = target.transform.origin
	look_at(target_position, Vector3.UP)
	
	var new_position = lerp(global_transform.origin, target_position + offset, follow_speed * delta) 
	global_transform.origin = new_position
