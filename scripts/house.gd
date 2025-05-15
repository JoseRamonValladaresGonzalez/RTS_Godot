extends Node2D
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var house_button: TextureButton = $HouseButton
@onready var menu_area: Area2D = $MenuArea
@onready var menu_shape: CollisionShape2D = $MenuArea/MenuShape
@onready var units_node = get_node("/root/World/Units")

var is_mouse_in_menu_area: bool = false
var unit_scene = preload("res://Scenes/unit.tscn") 
func _ready():
	# Configurar colisión del edificio
	var collision_shape = get_node("StaticBody2D/CollisionShape2D")
	collision_shape.set_deferred("disabled", false)
	
	# Configurar botón y menú
	house_button.mouse_filter = Control.MOUSE_FILTER_STOP
	v_box_container.hide()

func _on_house_button_pressed():
	var ui = get_tree().get_first_node_in_group("UI")
	if ui && !ui.building_mode_active:
		# Toggle simple de visibilidad
		v_box_container.visible = !v_box_container.visible

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


func _on_unit_button_pressed():
	spawn_unit()
