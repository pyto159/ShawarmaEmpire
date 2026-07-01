extends RefCounted
class_name QueueRequest

var requester: Node
var priority: int
var sequence_number: int


func _init(new_requester: Node, new_priority: int, new_sequence_number: int) -> void:
	requester = new_requester
	priority = new_priority
	sequence_number = new_sequence_number
