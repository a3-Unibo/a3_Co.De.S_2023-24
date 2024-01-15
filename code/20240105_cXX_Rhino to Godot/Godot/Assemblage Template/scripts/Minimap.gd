extends Camera3D
@export var target: NodePath

@onready var sub_viewport_container = $"../.."

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(target)
	sub_viewport_container.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = player.global_position + Vector3(0,2.2,0)
	
func _input(_event):
	if Input.is_action_just_pressed("minimapToggle"):
		sub_viewport_container.visible = not sub_viewport_container.visible
