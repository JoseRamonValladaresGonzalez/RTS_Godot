extends CharacterBody2D


signal died
@export var speed: float = 80.0
@export var attack_damage: int = 2
@export var attack_range: float = 50.0
@export var detection_range: float = 300.0

var health: int = 10:
	set(value):
		health = value
		if health <= 0:
			emit_signal("died")
			queue_free()

var current_target: Node = null

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer


func _ready():
	print("Enemigo listo. Configurando...")
	attack_timer.start()

func _physics_process(delta):
	if current_target and is_instance_valid(current_target):
		# Calcular dirección y movimiento
		var target_pos = current_target.global_position
		var direction = (target_pos - global_position).normalized()
		velocity = (current_target.global_position - global_position).normalized() * speed
		move_and_slide()  # Asegúrate de llamar esto SIEMPRE
		
		# Debug: Mostrar posición y velocidad
		print("Objetivo: ", current_target.name)
		print("Velocidad: ", velocity)
		
		# Manejar ataque
		if global_position.distance_to(target_pos) <= attack_range:
			try_attack()
	else:
		velocity = Vector2.ZERO  # Detener movimiento si no hay objetivo

func try_attack():
	if attack_timer.is_stopped():
		print("Atacando objetivo!")
		if current_target.has_method("take_damage"):
			current_target.take_damage(attack_damage)
			attack_timer.start()


func find_new_target():
	var targets = detection_area.get_overlapping_bodies()
	for body in targets:
		if is_valid_target(body):
			return body
	return null

func is_valid_target(body: Node) -> bool:
	return is_instance_valid(body) && \
		   body.is_inside_tree() && \
		   (body.is_in_group("players") || body.is_in_group("buildings") || body.is_in_group("unit"))
func take_damage(amount: int):
	health -= amount

func _on_attack_timer_timeout():
	# Verificación completa de validez del objetivo
	if is_instance_valid(current_target) && current_target.is_inside_tree():
		var distance = global_position.distance_to(current_target.global_position)
		if distance <= attack_range:
			current_target.take_damage(attack_damage)
	else:
		# Limpiar objetivo inválido
		current_target = null
		attack_timer.stop()
		print("Objetivo eliminado, buscando nuevo objetivo...")
		current_target = find_new_target()


func _on_detection_area_body_entered(body: Node2D) -> void:
	print("Cuerpo detectado: ", body.name)
	print("Grupos del cuerpo: ", body.get_groups())
	print("Es objetivo válido? ", is_valid_target(body))
	
	if is_valid_target(body):
		current_target = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == current_target:
		print("Objetivo perdido!")
		current_target = find_new_target()
		if current_target:
			print("Nuevo objetivo: ", current_target.name)

func update_targets(deleted_target: Node):
	if deleted_target == current_target:
		current_target = find_new_target()
		print("Objetivo principal eliminado, actualizando...")
