extends Node3D

var current_time = 0.0
@export var control_frequency = 60.0
var control_timeout: float
@export var lidar_sensor: RayCast3D
@export var speedometer: SmoothOperator
@export var cruise_speed = 26.82
@export var cruise_60mph_percent = 0.0981
@export var max_power = 101370.752
var cruise_60mph_power: float

# PID parameters
var error: float
var prev_error: float
var integral: float
var derivative: float
@export var Kp = 2.0 # proportional gain
@export var Ki = 0.1 # integral gain
@export var Kd = 0.0 # derivative gain

signal power_output(power: float)

func _ready():
	control_timeout = 1 / control_frequency
	cruise_60mph_power = max_power * cruise_60mph_percent

# This returns the distance to the vehicle in front of car
# assumes the car drives on a straight road so only accounts for z distance
# @TODO: make sensor slower and have noise
func get_sensor_data() -> float:
	if lidar_sensor.is_colliding():
		var distance = lidar_sensor.get_collision_point().z - lidar_sensor.global_position.z
		return abs(distance)
	else:
		return INF

# PID control loop
func control(current_speed: float, delta_time: float):
	var actual_distance = get_sensor_data()
	print("Distance to car: ", actual_distance)
	var target_speed: float
	
	# calculate target speed based on 2 second rule
	var maintain_distance = current_speed * 1.0
	print("Distance to maintain: ", maintain_distance)
	if actual_distance < maintain_distance:
		target_speed = actual_distance / 1.0
		target_speed = clamp(target_speed, 0.0, cruise_speed)
	else:
		target_speed = cruise_speed
	
	error = target_speed - current_speed
	integral += error * delta_time
	derivative = (error - prev_error) / delta_time
	
	var total_error = (error * Kp) + (integral * Ki) + (derivative * Kd)
	prev_error = error
	
	var cruise_power = (target_speed / 26.8224) * cruise_60mph_power
	var inertial_power = total_error * speedometer.mass * target_speed
	var total_power = cruise_power + inertial_power
	total_power = min(max(total_power, -max_power), max_power)
	power_output.emit(total_power)

func _physics_process(delta):
	if current_time >= control_timeout:
		control(speedometer.speed, control_timeout)
		current_time = 0.0
	else:
		current_time += delta
