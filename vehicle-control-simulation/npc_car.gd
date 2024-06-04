extends CharacterBody3D

func _physics_process(delta):
	velocity = Vector3.FORWARD * 15.0
	
	move_and_slide()
