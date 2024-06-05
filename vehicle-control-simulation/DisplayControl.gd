extends Control

@onready var speed_label = get_node("Panel/Speed")
@onready var power_label = get_node("Panel/Power")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func update_speed(speed):
	speed_label.text = "Speed: %d m/s" % speed

func update_power(power):
	power_label.text = "Power: %d N-m" % power
