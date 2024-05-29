extends CharacterBody3D

var gravity = 9.8

func _ready():
	pass

func _physics_process(delta):
#	velocity = Vector3.FORWARD * speed * delta
	velocity.y -= gravity * delta
	
	move_and_slide()
