extends CharacterBody3D

# Constants for the vehicle and environment
@export var rho: float = 1.3  # Air density (kg/m^3)
@export var frontal_area: float = 2.08  # Frontal area (m^2)
@export var Cd: float = 0.27  # Drag coefficient
@export var Cr: float = 0.0075  # Rolling resistance coefficient
@export var mass: float = 1474.0  # Vehicle mass (kg)
@export var gravity: float = 9.81  # Gravity (m/s^2)

var tolerance: float = 10.0
var max_iterations: int = 1000
var speed: float = 0.0

func calculate_power(v: float, dt: float) -> float:
	var P_aero = 0.5 * rho * frontal_area * Cd * v**3
	var P_rr = Cr * mass * gravity * v
	var P_inertial = mass * (v - speed)/dt * (v + speed)/2
	return P_aero + P_rr + P_inertial

# Velocity Approximation Algorithm
func calculate_speed(power: float, dt: float) -> float:
	var iteration = 0
	var current_speed = speed  # Start with the previous velocity
	var current_power = calculate_power(current_speed, dt)
	print(current_power, " ", power)

	while iteration < max_iterations:
		if abs(current_power - power) <= tolerance:
			print("break")
			break
		if current_power < power:
			current_speed += 0.1
			current_power = calculate_power(current_speed, dt)
		elif current_power > power:
			current_speed -= 0.1
			current_speed = max(current_speed, 0.0)
			current_power = calculate_power(current_speed, dt)
		iteration += 1
	
	print(iteration, " Speed: ", current_speed, " dt: ", dt)
	return current_speed

func _ready():
	pass

func _physics_process(delta):
	speed = calculate_speed(10000, delta)
	velocity = Vector3.FORWARD * speed
	
	velocity.y -= gravity * delta
	
	move_and_slide()


func _on_controller_power_output(power):
	pass
#	prev_speed = speed
#	speed = calculate_speed(power, prev_speed)
#	print(speed)
