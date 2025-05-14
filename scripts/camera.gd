extends Camera2D

signal area_selected(selection_rect: Rect2)

var is_dragging := false
var drag_start := Vector2()
var drag_end := Vector2()
@onready var panel: Panel = $"../Panel"

# Configuración de movimiento y zoom
var camera_speed := 500.0
var zoom_speed := 0.1
var min_zoom := Vector2(0.5, 0.5)
var max_zoom := Vector2(3.0, 3.0)
var target_zoom := Vector2.ONE
var move_direction := Vector2.ZERO

func _ready() -> void:

	target_zoom = zoom

func _process(delta: float) -> void:
	# Movimiento de la cámara
	if move_direction != Vector2.ZERO:
		position += move_direction.normalized() * camera_speed * delta * (1 / zoom.x)
	
	# Suavizado de zoom
	if zoom != target_zoom:
		zoom = zoom.lerp(target_zoom, delta * 10)
		zoom = zoom.clamp(min_zoom, max_zoom)

func _unhandled_input(event: InputEvent) -> void:
	# Manejo de movimiento WASD
	if event.is_action_pressed("move_right"):
		move_direction.x += 1
	elif event.is_action_released("move_right"):
		move_direction.x -= 1
	
	if event.is_action_pressed("move_left"):
		move_direction.x -= 1
	elif event.is_action_released("move_left"):
		move_direction.x += 1
	
	if event.is_action_pressed("move_up"):
		move_direction.y -= 1
	elif event.is_action_released("move_up"):
		move_direction.y += 1
	
	if event.is_action_pressed("move_down"):
		move_direction.y += 1
	elif event.is_action_released("move_down"):
		move_direction.y -= 1
	
	# Manejo de zoom con rueda del ratón
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom = (target_zoom - Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
			adjust_zoom_around_mouse(event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom = (target_zoom + Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
			adjust_zoom_around_mouse(event.position)
	
	# Selección rectangular (código original)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start = get_global_mouse_position()
			drag_end = drag_start

			if panel:
				panel.show()
				update_selection_panel()
		else:
			is_dragging = false
			drag_end = get_global_mouse_position()

			if panel:
				reset_panel()

			var rect := Rect2(
				drag_start.min(drag_end),
				(drag_start - drag_end).abs()
			)
			emit_signal("area_selected", rect)
	
	elif event is InputEventMouseMotion and is_dragging:
		drag_end = get_global_mouse_position()
		update_selection_panel()

func adjust_zoom_around_mouse(mouse_position: Vector2) -> void:
	# Ajusta el zoom manteniendo la posición del ratón como centro
	var old_zoom = zoom
	var mouse_world_pos = get_global_mouse_position()
	zoom = target_zoom
	var new_mouse_world_pos = get_global_mouse_position()
	position += (mouse_world_pos - new_mouse_world_pos)
	zoom = old_zoom  # Restaura el zoom hasta la interpolación

func update_selection_panel() -> void:
	if panel:
		var top_left := drag_start.min(drag_end)
		var size := (drag_start - drag_end).abs()
		panel.position = top_left
		panel.size = size + Vector2(1, 1)

func reset_panel() -> void:
	if panel:
		panel.hide()
		panel.position = Vector2.ZERO
		panel.size = Vector2.ZERO
