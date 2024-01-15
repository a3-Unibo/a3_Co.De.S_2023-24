extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true

func _input(_event):
	if Input.is_action_just_pressed("helpToggle"):
		visible = not visible
