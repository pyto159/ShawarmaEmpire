extends Marker2D
class_name SpawnPoint2D

signal reservation_changed(is_reserved: bool)

@export var is_enabled: bool = true

var is_reserved: bool = false


func can_spawn() -> bool:
	return is_enabled and not is_reserved


func reserve() -> void:
	_set_reserved(true)


func release() -> void:
	_set_reserved(false)


func _set_reserved(new_is_reserved: bool) -> void:
	if is_reserved == new_is_reserved:
		return

	is_reserved = new_is_reserved
	reservation_changed.emit(is_reserved)
