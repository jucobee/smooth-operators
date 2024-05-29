extends CharacterBody3D

var gravity = 9.8
var speed = 1000

@export var controller: Node
@export var cd: float
@export var cr: float

func _ready():
	pass

func _physics_process(delta):
	velocity = Vector3.FORWARD * speed * delta
	velocity.y -= gravity * delta
	
	move_and_slide()


func _on_controller_power_output():
	pass # Replace with function body.
