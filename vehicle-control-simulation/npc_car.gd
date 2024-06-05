extends CharacterBody3D

@export var speed_range = Vector2(15.0, 27.0)
@export var acceleration = 2.0
@onready var timer = $Timer
var speed = 27.0
var new_speed = 27.0

func _ready():
	timer.start()

func _physics_process(delta):
	speed = move_toward(speed, new_speed, acceleration * delta)
	velocity = Vector3.FORWARD * speed
	
	move_and_slide()


func _on_timer_timeout():
	new_speed = randf_range(speed_range.x, speed_range.y)
	timer.start()
