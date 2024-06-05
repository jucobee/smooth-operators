class_name SmoothOperator
extends CharacterBody3D

# Constants for the vehicle and environment
@export var rho: float = 1.3  # Air density (kg/m^3)
@export var frontal_area: float = 2.08  # Frontal area (m^2)
@export var Cd: float = 0.27  # Drag coefficient
@export var Cr: float = 0.0075  # Rolling resistance coefficient
@export var mass: float = 1474.0  # Vehicle mass (kg)
@export var gravity: float = 9.81  # Gravity (m/s^2)

var tolerance: float = 0.01
var max_iterations: int = 100
var speed: float = 0.0
var power: float = 0.0

@onready var display = get_node("../Display/DisplayControl")

# Velocity from Power Input Approximation Algorithm
# Newton's Method: v1 = v0 - (F(v) / F'(v))
func calculate_speed(power: float, v_old: float, delta: float) -> float:
	var error = 1.0
	var iteration = 0
	var v = v_old  # Start with the previous velocity

	while iteration < max_iterations:
		var P_aero = 0.5 * rho * frontal_area * Cd * v**3
		var P_rr = Cr * mass * gravity * v
		var P_inertial = mass * (v - v_old)/delta * (v + v_old)/2
		var Fv = power - (P_aero + P_rr + P_inertial)

		var P_aero_prime = 1.5 * rho * frontal_area * Cd * v**2
		var P_rr_prime = Cr * mass * gravity
		var P_inertial_prime = mass * v / delta
		var Fv_prime = -(P_aero_prime + P_rr_prime + P_inertial_prime)

		var v_new = v - (Fv / Fv_prime)  # Apply damping to adjustment
		error = abs(v_new - v)
		v = v_new
		iteration += 1

		if error <= tolerance:
			break
	return v


func _physics_process(delta):
	speed = calculate_speed(power, speed, delta)
	velocity = Vector3.FORWARD * speed
	
	velocity.y -= gravity * delta
	
	display.update_speed(speed * 2.23694)
	display.update_power(power / 1000)
	
	move_and_slide()


func _on_controller_power_output(power):
	self.power = power
