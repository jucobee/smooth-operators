extends CharacterBody3D

# Constants for the vehicle and environment
@export var rho: float = 1.3  # Air density (kg/m^3)
@export var frontal_area: float = 2.2  # Frontal area (m^2)
@export var Cd: float = 0.3  # Drag coefficient
@export var Cr: float = 0.015  # Rolling resistance coefficient
@export var mass: float = 1500.0  # Vehicle mass (kg)
@export var gravity: float = 9.81  # Gravity (m/s^2)

# Velocity Approximation Algorithm
## do this to avoid dealing with finding velocity from power equations
var tolerance: float = 0.1
var max_iterations: int = 100
var acceleration: float = 0.0
var prev_velocity: float = 0.0

func calculate_velocity(power: float, v_old: float, delta: float) -> float:
	var error = 1.0
	var iteration = 0
	var v = v_old  # Start with the previous velocity

	# Newton-Raphson Method
	while iteration < max_iterations:
		var P_aero = 0.5 * rho * frontal_area * Cd * v**3
		var P_rr = Cr * mass * gravity * v
		var P_inertial = mass * acceleration * v
		var Fv = power - (P_aero + P_rr + P_inertial)
		
		var P_aero_prime = 1.5 * rho * frontal_area * Cd * v**2
		var P_rr_prime = Cr * mass * gravity
		var P_inertial_prime = mass * acceleration
		var Fv_prime = -(P_aero_prime + P_rr_prime + P_inertial_prime)

		var v_new = v - Fv / Fv_prime
		error = abs(v_new - v)
		v = v_new
		iteration += 1
		
		if error <= tolerance:
			break
	
	acceleration = (v - v_old) / delta
	return v

func _ready():
	prev_velocity = 25.0

func _physics_process(delta):
	velocity = Vector3.FORWARD * calculate_velocity(10000, prev_velocity, delta)
	prev_velocity = -velocity.z
	velocity.y -= gravity * delta
	
	move_and_slide()

