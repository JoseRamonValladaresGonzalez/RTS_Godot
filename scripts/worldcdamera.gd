extends Camera2D


func _ready():
	zoom = Vector2(0.1, 0.1)  # Ajusta según el tamaño de tu mundo
	limit_left = 0
	limit_right = 2000  # Igual que world_bounds
	limit_top = 0
	limit_bottom = 2000
	position = Vector2(1000, 1000)  # Centrado si el mundo es 2000x2000
