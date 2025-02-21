class_name Health
extends Node

signal max_health_changed(diff: float)
signal health_changed(diff: float)
signal health_depleted

@export
var max_health: float = 3.0
@export
var immortality: bool = false #USE DURING SOME ANIMATIONS OR AFTER RESPAWN FOR A FEW SECONDS

var immortality_timer: Timer = null

@onready
var health: float = max_health
