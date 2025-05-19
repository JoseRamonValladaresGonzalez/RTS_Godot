extends Control

@export var world_bounds: Rect2 = Rect2(0, 0, 2000, 2000)
@export var main_camera: Camera2D
@export var player_color: Color = Color.WHITE
@export var enemy_color: Color = Color.RED
@export var building_color: Color = Color.ROYAL_BLUE
@export var resource_color: Color = Color.FOREST_GREEN
@export var resource_size: int = 3

@onready var subviewport_container: SubViewportContainer = $SubViewportContainer
@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var markers_container: Control = $MarkersContainer
@onready var click_area: TextureButton = $ClickArea
@onready var camera_rect: ColorRect = $CameraRect  # Asegúrate de tener este nodo

var minimap_size: Vector2:
	get: return Vector2(subviewport_container.size)  # Conversión a Vector2

func _ready():
	# Esperar a que la escena principal esté lista
	await get_tree().process_frame
	
	# Configurar Viewport después de la carga
	subviewport.size = subviewport_container.size
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# Configurar área de clic
	click_area.custom_minimum_size = subviewport_container.size
	click_area.position = Vector2.ZERO
	click_area.pressed.connect(_on_minimap_clicked)
	


func _process(delta):
	if is_instance_valid(main_camera):
		queue_redraw()
		update_markers()

func _draw():
	if is_instance_valid(main_camera):
		var cam_rect = _get_camera_rect()
		draw_rect(cam_rect, Color.GOLD, false, 1.0)

func update_markers():
	for child in markers_container.get_children():
		child.queue_free()
	_create_markers_group("enemies", enemy_color, 3)
	_create_markers_group("units", player_color, 2)
	_create_markers_group("buildings", building_color, 4)
	_create_markers_group("resources", resource_color, resource_size)

func _create_markers_group(group: String, color: Color, size: int):
	for node in get_tree().get_nodes_in_group(group):
		if node.is_inside_tree():
			var marker = Control.new()
			marker.custom_minimum_size = Vector2(size, size)
			marker.position = _world_to_minimap(node.global_position) - Vector2(size/2, size/2)
			
			var texture_rect = TextureRect.new()
			texture_rect.texture = _create_circle_texture(size, color)
			marker.add_child(texture_rect)
			
			markers_container.add_child(marker)

func _create_circle_texture(size: int, color: Color) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func _world_to_minimap(world_pos: Vector2) -> Vector2:
	# Usar el tamaño real del Control para el mapeo
	var x = remap(world_pos.x, world_bounds.position.x, world_bounds.end.x, 0, size.x)
	var y = remap(world_pos.y, world_bounds.position.y, world_bounds.end.y, 0, size.y)
	return Vector2(x, y)

func _get_camera_rect() -> Rect2:
	if not is_instance_valid(main_camera):
		return Rect2()
	
	# Limitar posición de la cámara
	var clamped_pos = Vector2(
		clamp(main_camera.global_position.x, world_bounds.position.x, world_bounds.end.x),
		clamp(main_camera.global_position.y, world_bounds.position.y, world_bounds.end.y)
	)
	
	var viewport_size = Vector2(get_viewport().size) / main_camera.zoom
	var cam_half_size = viewport_size / 2
	var top_left = _world_to_minimap(clamped_pos - cam_half_size)
	var bottom_right = _world_to_minimap(clamped_pos + cam_half_size)
	
	return Rect2(top_left, bottom_right - top_left)
func _on_minimap_clicked():
	if is_instance_valid(main_camera):
		# Obtener posición del clic relativa al Control del minimapa
		var click_pos = get_local_mouse_position()
		
		# Convertir a coordenadas normalizadas (0-1)
		var normalized_pos = Vector2(
			click_pos.x / size.x,
			click_pos.y / size.y
		)
		
		# Calcular posición del mundo CENTRADA en la cámara
		var world_pos = Vector2(
			lerp(world_bounds.position.x, world_bounds.end.x, normalized_pos.x),
			lerp(world_bounds.position.y, world_bounds.end.y, normalized_pos.y)
		)
		
		# Centrar la cámara en la posición calculada
		main_camera.global_position = world_pos
		get_viewport().set_input_as_handled()
