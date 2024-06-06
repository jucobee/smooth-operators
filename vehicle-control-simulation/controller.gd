class_name Controller
extends Node3D

# Components controller needs access to
@export var lidar_sensor: RayCast3D
# distance to vehicle ahead that the sensor returns in the previous timestep
var prev_distance: float = 0.0 
@export var vehicle: SmoothOperator

# User specified cruise speed
@export var cruise_speed = 26.82

# Actual speed the vehicle is currently going
# Updated by the vehicle script as a sort of "speedometer"
var actual_speed: float

# These values will be initialized by the vehicle script
var max_power: float
var cruise_60mph_power: float
var mass: float

# Variables for setting frequency of controller's operations & output
@export var control_frequency = 60.0
var current_time = 0.0
var control_timeout: float

# PID parameters
var error: float
var prev_error: float
var integral: float
var derivative: float
@export var Kp = 2.0 # proportional gain
@export var Ki = 0.1 # integral gain
@export var Kd = 0.0 # derivative gain

# Signal that tells the vehicle how much power to output
signal power_output(power: float)


# Ready is called before the simulator starts
func _ready():
	control_timeout = 1 / control_frequency


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
	var target_speed: float
	var maintain_distance: float
	
	# If sensor detects we are moving toward a vehicle faster than it's moving away from us
	if actual_distance < prev_distance and prev_distance < INF:
		# Speed of the vehicle ahead of us
		var maintain_speed = current_speed - (prev_distance - actual_distance) / delta_time
		
		# Distance we should stay behind it based on 3 sec rule
		maintain_distance = maintain_speed * 3.0
		
		# Calculate acceleration to reach maintenance distance using equations of motion
		var acceleration = (maintain_speed**2 - current_speed**2) / maintain_distance
		target_speed = move_toward(target_speed, maintain_speed, abs(acceleration) * delta_time)
	
	# Otherwise speed should be the user-defined cruise speed
	else:
		target_speed = cruise_speed
	
	# Make sure target speed isn't too high or too low
	target_speed = clamp(target_speed, 0.0, cruise_speed)
	
	# Calculate PID error
	error = target_speed - current_speed
	integral += error * delta_time
	derivative = (error - prev_error) / delta_time
	
	var total_error = (error * Kp) + (integral * Ki) + (derivative * Kd)
	prev_error = error
	
	# Calculate output power from speed, taking into account error
	var cruise_power = (target_speed / 26.8224) * cruise_60mph_power
	var inertial_power = total_error * mass * target_speed
	var total_power = cruise_power + inertial_power
	total_power = min(max(total_power, -max_power), max_power)
	
	# Signal engine what power to output
	# This also signals the HUD what distance to display
	power_output.emit(total_power, actual_distance)
	
	prev_distance = actual_distance


func _physics_process(delta):
	if current_time >= control_timeout:
		control(actual_speed, control_timeout)
		current_time = 0.0
	else:
		current_time += delta
