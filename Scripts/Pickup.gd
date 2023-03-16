extends Area

onready var navMesh: NavigationMeshInstance  = get_tree().get_nodes_in_group("navmesh")[0]

var navMeshVertices: Array

func _ready():	
	connect("body_entered", self, "_on_body_entered")
	if navMesh:
		navMeshVertices = navMesh.navmesh.vertices
		pickAnotherSpot()


func _on_body_entered(body):
	if body is VehicleBody:
		pickAnotherSpot()


func pickAnotherSpot():
	translation = navMeshVertices[randi() % navMeshVertices.size()]

