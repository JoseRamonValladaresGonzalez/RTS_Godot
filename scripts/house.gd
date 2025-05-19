extends Node2D
@onready var house_menu: VBoxContainer = $HouseMenu


@onready var area_2d: Area2D = $Area2D
@onready var click_area: CollisionShape2D = $Area2D/ClickArea
@onready var units_node = get_node("/root/World/Units")

var is_mouse_in_menu_area: bool = false
var unit_scene = preload("res://Scenes/unit.tscn") 
func _ready():
	# Configurar colisión del edificio
	var collision_shape = get_node("StaticBody2D/CollisionShape2D")
	collision_shape.set_deferred("disabled", false)
	
	house_menu.hide()


func spawn_unit():
	if Global.food >= 20 && Global.wood >= 10:
		Global.food -= 20
		Global.wood -= 10
		
		var new_unit = unit_scene.instantiate()
		units_node.add_child(new_unit)  # Añade al contenedor Units
		
		new_unit.global_position = global_position + Vector2(50, 30)
		new_unit.add_to_group("unit")
		
		if new_unit is CharacterBody2D:
			new_unit.collision_layer = 1
			new_unit.collision_mask = 0b110
		else:
			printerr("ERROR: No se encontró el nodo Units!")
			return
		
		# Configurar posición, grupo y colisiones
		new_unit.global_position = global_position + Vector2(180, 30)
		new_unit.add_to_group("unit")
		
		if new_unit is CharacterBody2D:
			new_unit.collision_layer = 1  # Layer 1
			new_unit.collision_mask = 0b110  # Layers 2 y 3 (6 en decimal)
		else:
			printerr("La unidad no tiene CharacterBody2D como raíz!")
		
	else:
		print("Recursos insuficientes!")


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		house_menu.visible = !house_menu.visible


func _on_summon_button_pressed() -> void:
	spawn_unit()
