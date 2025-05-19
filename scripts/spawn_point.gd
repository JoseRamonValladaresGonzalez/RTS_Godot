extends Marker2D

@export var enemy_scene: PackedScene  # Asigna la escena del enemigo en el editor
@export var spawn_interval: float = 5.0  # Tiempo entre generaciones en segundos

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_spawn_timer_timeout)
	timer.start()

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scene == null:
		push_error("No hay escena de enemigo asignada!")
		return
	
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = global_position
	print("Enemigo generado en: ", global_position)
