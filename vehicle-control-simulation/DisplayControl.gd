extends Control

@onready var speed_label = $GridContainer/Speed
@onready var power_label = $GridContainer/Power

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func update_speed(speed):
	speed_label.text = "Speed: %d MPH" % speed

func update_power(power):
	power_label.text = "Power: %d kW" % power
