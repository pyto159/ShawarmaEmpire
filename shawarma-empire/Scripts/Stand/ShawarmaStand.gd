class_name ShawarmaStand
extends Node2D
## Visual shell for the shawarma stand.
##
## The stand exposes reusable marker points for customer flow while keeping
## ordering, money, and upgrade systems out of this first loop.

@onready var customer_waiting_point: Marker2D = $CustomerWaitingPoint
@onready var customer_exit_point: Marker2D = $CustomerExitPoint
