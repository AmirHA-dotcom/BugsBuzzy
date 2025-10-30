extends Node

@export var timer_duration: float = 5.0  # Time in seconds
var time_left: float = timer_duration

@onready var timer = $SubViewport/GameTimer  # Timer node
@onready var label = $SubViewport/TimerLabel  # Timer Label node

func _ready():
	# Set up the timer properties
	timer.wait_time = 1.0  # Timer fires every 1 second
	timer.one_shot = false  # Repeat every 1 second
	timer.start()  # Start the timer
	update_timer_display()  # Update the initial display

func _process(delta: float):
	if time_left <= 0:
		return  # If time is 0, no further updates

	# Decrement the time every second
	if timer.time_left == 0:
		time_left -= 1
		update_timer_display()

		# Check if time is up
		if time_left <= 0:
			print("Game Over")
			# Optionally, stop the game or trigger any other actions
			timer.stop()

# Function to update the timer display
func update_timer_display():
	label.text = "Time: " + str(time_left)  # Show the remaining time
