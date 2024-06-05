class_name SmoothOperator
extends CharacterBody3D

# Constants for the vehicle and environment
@export var rho: float = 1.3  # Air density (kg/m^3)
@export var frontal_area: float = 2.08  # Frontal area (m^2)
@export var Cd: float = 0.27  # Drag coefficient
@export var Cr: float = 0.0075  # Rolling resistance coefficient
@export var mass: float = 1474.0  # Vehicle mass (kg)
@export var gravity: float = 9.81  # Gravity (m/s^2)

# Variables updated as simulator runs
var speed: float = 0.0 # current speed in m/s
var power: float = 0.0 # current power in Watts

# Current distance to car in front, updated from the controller script
# Only used in this script to display on the HUD
var distance: float = 0.0 

# Heads Up Display (HUD)
@onready var display = get_node("../Display/DisplayControl")

# Two different POV's to switch between
@export var camera1: Camera3D # Behind view
@export var camera2: Camera3D # Bird's eye view

# Find velocity from power input using approximation algorithm
# Newton's Method: v1 = v0 - (F(v) / F'(v))
var tolerance: float = 0.01 # Error tolerance for approx
var max_iterations: int = 100

func calculate_speed(power: float, v_old: float, delta: float) -> float:
	var error = 1.0
	var iteration = 0
	var v = v_old  # Start with the previous velocity
	
	# Since we want to run this sim in real-time, 
	# we don't want to get stuck in a while loop
	while iteration < max_iterations:
		# F(v) calculation
		var P_aero = 0.5 * rho * frontal_area * Cd * v**3
		var P_rr = Cr * mass * gravity * v
		var P_inertial = mass * (v - v_old)/delta * (v + v_old)/2
		var Fv = power - (P_aero + P_rr + P_inertial)
		
		# F'(v) calculation
		var P_aero_prime = 1.5 * rho * frontal_area * Cd * v**2
		var P_rr_prime = Cr * mass * gravity
		var P_inertial_prime = mass * v / delta
		var Fv_prime = -(P_aero_prime + P_rr_prime + P_inertial_prime)

		var v_new = v - (Fv / Fv_prime)
		error = abs(v_new - v)
		v = v_new
		iteration += 1

		if error <= tolerance:
			break
	return v


# PID Controller updates how much power for the engine to output
func _on_controller_power_output(power):
	self.power = power


# Called every physics frame (60 fps)
func _physics_process(delta):
	# Calculate speed from power using approximation algorithm
	speed = calculate_speed(power, speed, delta)
	
	# Update CharacterController3D's velocity based on this calculation
	velocity = Vector3.FORWARD * speed
	
	# Apply gravity
	velocity.y -= gravity * delta
	
	# CharacterController3D function to actually move the object
	move_and_slide()
	
	# Update HUD
	display.update_speed(speed * 2.23694)
	display.update_power(power / 1000)
	display.update_distance(distance * 3.280839895)
	
	# Ability to switch camera perspectives
	if Input.is_physical_key_pressed(KEY_1):
		camera2.current = false
		camera1.current = true
	elif Input.is_physical_key_pressed(KEY_2):
		camera1.current = false
		camera2.current = true
