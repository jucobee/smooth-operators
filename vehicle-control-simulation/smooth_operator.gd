extends CharacterBody3D

var gravity = 9.8
var speed = 1000
var force = 100

@export var controller: Node
@export var cd: float
@export var cr: float
@export var mass: float
@export var frontal_area: float

func _ready():
	pass

func _physics_process(delta):
	#velocity = Vector3.FORWARD * speed * delta
	velocity.y -= gravity * delta
	velocity = Vector3.FORWARD * sqrt(2 * (force - (cr * mass * gravity))/(cd * 1.3 * frontal_area))
	
	
	move_and_slide()


func _on_controller_power_output():
	pass # Replace with function body.
