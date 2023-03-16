extends VehicleBody

export var horsepower: float = 125
export var acceleration: float = 1

export var steer_limit = deg2rad(36)

var reset_car_pos: bool = false

onready var navAgent = $NavigationAgent
onready var carFront = $carFrontPosition3D

onready var stoppage_timer = $Timers/stoppageTimer
var stopped: bool = false

var targetDir: Vector3

onready var pickups = get_tree().get_nodes_in_group("pickup")

func _ready():
	navAgent.connect("velocity_computed", self, "_on_velocity_computed")
	stoppage_timer.connect("timeout", self, "_on_stoppage_timer_timeout")


func _physics_process(delta):
	var chosenPickup = select_nearest_pickup(pickups)
	pickup_processing(chosenPickup)
	init_stoppage_test()
	
	
	var drive_input = 1
	engine_force = lerp(engine_force, drive_input * horsepower, acceleration * delta)
#	var steer_input = angle_dir(carFront.global_transform.basis.z, targetDir.normalized(), carFront.global_transform.basis.y)
	var steer_input = angle_dir(global_transform.basis.z, targetDir.normalized(), global_transform.basis.y)
	steering = steer_input * steer_limit


func pickup_processing(pickup):
	var pickupLocation = navAgent.set_target_location(pickup.global_transform.origin)
	var nextPathPoint = navAgent.get_next_location()
	var dir = global_transform.origin.direction_to(nextPathPoint)
	var velocity = dir * navAgent.max_speed
	navAgent.set_velocity(velocity)


func angle_dir(fwd, target, up):
	var p = fwd.cross(target)
	var dir = p.dot(up)
	return dir


func _integrate_forces(state):
	if reset_car_pos:
		var tPos = navAgent.get_next_location()
		var randBasis = Basis.IDENTITY.rotated(Vector3.UP, deg2rad(randi() % 360))
		var chosenTransform = Transform(randBasis, tPos)
		state.set_transform(chosenTransform)
		reset_car_pos = false


func _on_velocity_computed(vel):
	targetDir = vel


func stop_test():
	stopped = true if linear_velocity.length_squared() < 1.0 else false
	return stopped


func init_stoppage_test():
	if stoppage_timer.is_stopped() and stop_test():
		stoppage_timer.start()


func _on_stoppage_timer_timeout():
	if stoppage_timer.is_stopped() and stop_test():
		reset_car_pos = true


func select_nearest_pickup(pickupArray):
	var pickupComparisonArray = []
	for pickup in pickupArray:
		var dist= global_transform.origin.distance_squared_to(pickup.global_transform.origin)
		pickupComparisonArray.append(dist)
	var closestDistance = pickupComparisonArray.min()
	var nearestPickup = pickupArray[pickupComparisonArray.find(closestDistance)]
	var pickupPos = nearestPickup.global_transform.origin
	navAgent.set_target_location(pickupPos)
	return nearestPickup
