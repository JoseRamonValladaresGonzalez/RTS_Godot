extends Node2D

@export var attack_range: float = 300.0
@export var attack_damage: int = 2
@export var attack_cooldown: float = 1.5

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer
@onready var shooting_point: Marker2D = $ShootingPoint

var current_target: Node = null
var enemies_in_range: Array = []

func _ready():
	attack_timer.wait_time = attack_cooldown
	attack_timer.start()

func _physics_process(delta):
	if enemies_in_range.is_empty():
		current_target = null
		return
	
	# Buscar el enemigo más cercano
	var closest_distance = INF
	var closest_enemy = null
	
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy
	
	current_target = closest_enemy
	
	# Rotar hacia el objetivo
	if current_target:
		look_at(current_target.global_position)


func _on_attack_timer_timeout():
	if current_target and is_instance_valid(current_target):
		shoot()

func shoot():
	if not current_target or !is_instance_valid(current_target):
		return
	
	var projectile = preload("res://Scenes/projectile.tscn").instantiate()
	# Añadir al nodo raíz en lugar del padre directo
	get_tree().root.add_child(projectile)
	
	projectile.global_position = shooting_point.global_position
	projectile.init(current_target, attack_damage)
	projectile.rotation = global_rotation
	
	attack_timer.start()

func _on_destroyed():
	queue_free()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if not enemies_in_range.has(body):
			enemies_in_range.append(body)
			if not attack_timer.is_stopped():
				attack_timer.start()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.erase(body)
