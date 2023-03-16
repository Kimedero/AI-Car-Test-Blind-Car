extends Area

func _ready():
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if body is VehicleBody:
		body.reset_car_pos = true
#		print(body, " fell through, eh?!")

