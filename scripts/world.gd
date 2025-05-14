extends Node2D

@onready var units = $Units
@onready var camera: Camera2D = $Camera
@onready var building_scene = preload("res://scenes/building.tscn")
var selected_units: Array[CharacterBody2D] = []
var building_type = ""
var preview_instance: Node2D = null

func _ready():
	camera.area_selected.connect(_on_area_selected)
	$UI.building_mode_changed.connect(_on_building_mode_changed)
	
	# Conectar señales de recursos solo una vez al inicio
	for res in get_tree().get_nodes_in_group("resources"):
		if res.has_signal("resource_harvested") && !res.resource_harvested.is_connected(_on_resource_harvested):
			res.resource_harvested.connect(_on_resource_harvested)

func _on_building_mode_changed(enabled: bool, type: String):
	if enabled:
		building_type = type
		create_preview()
	else:
		clear_preview()

func create_preview():
	preview_instance = building_scene.instantiate()
	var static_body = preview_instance.get_node("StaticBody2D")
	static_body.set_deferred("disabled", true)
	add_child(preview_instance)

func clear_preview():
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null

func _process(delta):
	if preview_instance:
		update_preview_position()

func update_preview_position():
	var mouse_pos = get_global_mouse_position()
	preview_instance.global_position = mouse_pos
	preview_instance.modulate = Color.GREEN if is_valid_placement() else Color.RED

func is_valid_placement() -> bool:
	if !preview_instance: 
		return false
	
	var space = get_world_2d().direct_space_state
	var shape = preview_instance.get_node("StaticBody2D/CollisionShape2D").shape
	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = preview_instance.global_transform
	params.collision_mask = 1
	
	return space.intersect_shape(params).is_empty()

func try_place_building():
	if is_valid_placement() and Global.can_afford(building_type):
		place_building()
		Global.deduct_resources(building_type)
		clear_preview()

func place_building():
	var new_building = building_scene.instantiate()
	new_building.global_position = preview_instance.global_position
	add_child(new_building)

func _on_resource_harvested(type: String, amount: int):
	match type:
		"wood":
			Global.wood += amount
		"stone":
			Global.stone += amount
		"gold":
			Global.gold += amount
		"food":
			Global.food += amount


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT and preview_instance:
				try_place_building()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				clear_preview()
				
				# Movimiento de unidades
				var mouse_pos = get_global_mouse_position()
				var space_state = get_world_2d().direct_space_state
				var ray_query = PhysicsRayQueryParameters2D.create(camera.position, mouse_pos)
				var result = space_state.intersect_ray(ray_query)
				var resource_target = null
				
				if result:
					var collider = result["collider"]
					if collider.is_in_group("resources"):
						resource_target = collider
				
				for unit in selected_units:
					if resource_target:
						unit.move_to(resource_target.global_position, resource_target)
					else:
						unit.move_to(mouse_pos, null)

func _on_area_selected(rect: Rect2):
	selected_units.clear()
	for unit in units.get_children():
		if rect.has_point(unit.global_position):
			unit.select()
			selected_units.append(unit)
		else:
			unit.deselect()
