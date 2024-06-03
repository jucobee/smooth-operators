extends Node3D

var current_time = 0.0
@export var control_frequency = 60.0
var control_timeout: float
@export var lidar_sensor: RayCast3D
@export var cruise_speed = 26.82
@export var desired_distance = 26.82 # @TODO: Make this based on speed, not a set value

# PID parameters
var error: float
var prev_error: float
var integral: float
var derivative: float
@export var Kp = 1.0 # proportional gain
@export var Ki = 0.0 # integral gain
@export var Kd = 0.0 # derivative gain

signal power_output(power: float)

func _ready():
	control_timeout = 1 / control_frequency

# returns the distance to the vehicle in front of car
# assumes the car drives on a straight road so only accounts for z distance
# @TODO: make sensor slower and have noise
func get_sensor_data() -> float:
	if lidar_sensor.is_colliding():
		var distance = lidar_sensor.get_collision_point().z - self.global_position.z
		return distance
	else:
		return INF

# PID control loop
func control(maintain_distance: float, delta_time):
	var actual_distance = get_sensor_data()
	
	if actual_distance != INF:
		error = maintain_distance - actual_distance
		integral += error * delta_time
		derivative = (error - prev_error) / delta_time
		
		var total_error = (error * Kp) + (integral * Ki) + (derivative * Kd)
		prev_error = error
		
		# convert distance error to speed
		
		power_output.emit(1000)
	else:
		power_output.emit(10000)

func _physics_process(delta):
	if current_time >= control_timeout:
		control(desired_distance, control_timeout)
		current_time = 0.0
	else:
		current_time += delta
