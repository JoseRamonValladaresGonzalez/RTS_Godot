# ResourceNode.gd
extends StaticBody2D

@export var resource_amount: int = 100
@export var harvest_time: float = 3.0
@export var resource_type: String = "wood"  # wood, stone, gold, etc.

@onready var area_2d: Area2D = $Area2D
@onready var progress_bar: ProgressBar = $ProgressBar

signal resource_harvested(type: String, amount: int)

var harvesting := false
var harvest_timer := 0.0
var current_unit: CharacterBody2D = null

func _ready():
	add_to_group("resources")
	progress_bar.global_position = global_position + Vector2(-30, -60)
	progress_bar.top_level = true

func start_harvest(unit: CharacterBody2D):
	if harvesting or resource_amount <= 0:
		return
	
	harvesting = true
	current_unit = unit
	harvest_timer = 0.0
	progress_bar.value = 0
	progress_bar.max_value = harvest_time
	progress_bar.position = global_position + Vector2(-50, -60)
	progress_bar.visible = true

	if not unit.is_connected("moving_started", Callable(self, "_on_unit_moved")):
		unit.connect("moving_started", Callable(self, "_on_unit_moved"))

func _process(delta):
	if harvesting:
		harvest_timer += delta
		progress_bar.value = harvest_timer
		
		if harvest_timer >= harvest_time:
			finish_harvest()

func finish_harvest():
	harvesting = false
	progress_bar.visible = false
	resource_amount -= 10
	emit_signal("resource_harvested", resource_type, 10)
	if resource_amount <= 0:
		queue_free()
	else:
		start_harvest(current_unit)

func _on_unit_moved():
	if harvesting:
		harvesting = false
		progress_bar.visible = false
