extends Control

@export var world_bounds: Rect2 = Rect2(0, 0, 2000, 2000)  # Ajustar al tamaño real del mapa
@export var camera_path: NodePath  # Asignar en el editor la cámara principal
@export var player_color: Color = Color.WHITE
@export var enemy_color: Color = Color.RED
@export var building_color: Color = Color.ROYAL_BLUE
@export var camera: Camera2D
@onready var markers_container: Control = $MarkersContainer
@export var resource_color: Color = Color.FOREST_GREEN  # Nuevo color para recursos
@export var resource_size: int = 3  # Tamaño de marcadores de recursos

func _ready():

	add_to_group("UI")
	size = custom_minimum_size
	$ClickArea.pressed.connect(_on_minimap_clicked)
	$ClickArea.custom_minimum_size = size
	$ClickArea.position = Vector2.ZERO
	$ClickArea.size = size
	$ClickArea.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if not camera:
		printerr("¡Cámara no asignada en el minimapa!")
		return

func _process(delta):
	queue_redraw()
	update_markers()

func _draw():
	# Dibujar área visible de la cámara
	var cam_rect = _get_camera_rect()
	draw_rect(cam_rect, Color.GOLD, false, 1.0)

func update_markers():
	# Limpiar marcadores antiguos
	for child in markers_container.get_children():
		child.queue_free()
	
	# Dibujar unidades
	for unit in get_tree().get_nodes_in_group("units"):
		_create_marker(unit.global_position, player_color, 2)
	
	# Dibujar edificios
	for building in get_tree().get_nodes_in_group("buildings"):
		_create_marker(building.global_position, building_color, 4)
	
	for resource in get_tree().get_nodes_in_group("resources"):
		_create_marker(resource.global_position, resource_color, resource_size)

func _create_marker(position: Vector2, color: Color, size: int):
	var marker = Control.new()
	marker.custom_minimum_size = Vector2(size, size)
	marker.position = _world_to_minimap(position) - Vector2(size/2, size/2)
	
	var texture_rect = TextureRect.new()
	texture_rect.texture = create_circle_texture(size, color)
	
	marker.add_child(texture_rect)
	markers_container.add_child(marker)

func create_circle_texture(size: int, color: Color) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func _world_to_minimap(world_pos: Vector2) -> Vector2:
	var normalized = (world_pos - world_bounds.position) / world_bounds.size
	return normalized * size

func _get_camera_rect() -> Rect2:
	if not is_instance_valid(camera):
		return Rect2()
	
	# Limitar posición de la cámara a los bordes del mundo
	var clamped_pos = Vector2(
		clamp(camera.global_position.x, world_bounds.position.x, world_bounds.end.x),
		clamp(camera.global_position.y, world_bounds.position.y, world_bounds.end.y)
	)
	
	var viewport_size: Vector2 = Vector2(get_viewport().size) / camera.zoom
	var camera_half_size = viewport_size / 2.0
	
	var top_left = _world_to_minimap(clamped_pos - camera_half_size)
	var bottom_right = _world_to_minimap(clamped_pos + camera_half_size)
	
	# Asegurar que el rectángulo no salga del minimapa
	var minimap_rect = Rect2(Vector2.ZERO, size)
	return Rect2(top_left, bottom_right - top_left).intersection(minimap_rect)
func _on_minimap_clicked():
	# Obtener rectángulo global del minimapa
	var minimap_global_rect = get_global_rect()
	var mouse_global_pos = get_global_mouse_position()
	
	# Verificar si el clic está dentro del área VISUAL real
	if minimap_global_rect.has_point(mouse_global_pos):
		# Convertir a coordenadas relativas al minimapa
		var local_pos = get_local_mouse_position()
		var world_pos = (local_pos / size) * world_bounds.size + world_bounds.position
		camera.global_position = world_pos
		get_viewport().set_input_as_handled()  # ¡Importante!
	else:
		return
