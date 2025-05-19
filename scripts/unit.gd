extends CharacterBody2D

@export var selected: bool = false:
	set(value):
		selected = value
		box.visible = selected
@export var max_health: int = 10
var health: int = max_health:
	set(value):
		health = clamp(value, 0, max_health)
		if health <= 0:
			die()

@export var speed: float = 200.0
@export var separation_force: float = 300.0
@export var separation_radius: float = 60.0

@onready var box: Panel = $Box
@onready var separation_area: Area2D = $SeparationArea
signal moving_started
signal died
var target_position: Vector2 = Vector2.ZERO
var moving: bool = false
var target_resource: Node = null

var nearby_units: Array = []

@export var attack_range: float = 150.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.0

var attack_target: Node = null
var can_attack: bool = true
var is_attacking: bool = false


func _ready():
	box.visible = selected
	setup_separation_area()
	$AttackCooldown.timeout.connect(_on_attack_cooldown_timeout)
	health = max_health

func take_damage(amount: int):
	health -= amount

func die():
	# Añadir estas líneas antes de queue_free()
	if attack_target != null && attack_target.has_method("update_targets"):
		attack_target.update_targets(self)
	emit_signal("died")
	queue_free()


func setup_separation_area():
	var shape = CircleShape2D.new()
	shape.radius = separation_radius
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	separation_area.add_child(collision_shape)
	separation_area.body_entered.connect(_on_body_entered)
	separation_area.body_exited.connect(_on_body_exited)

func select():
	selected = true

func deselect():
	selected = false

func move_to(pos: Vector2, target_resource_node: Node = null):
	target_position = pos
	moving = true
	emit_signal("moving_started")
	target_resource = target_resource_node

func _physics_process(delta: float):
	if moving:
		var target_direction = (target_position - global_position).normalized()
		var separation = calculate_separation()
		
		var final_direction = (target_direction + separation).normalized()
		velocity = final_direction * speed
		
		move_and_slide()
		check_arrival()
		check_collisions()
	elif attack_target and is_attacking:
		handle_attack()

func calculate_separation() -> Vector2:
	var separation_vector = Vector2.ZERO
	for unit in nearby_units:
		var to_unit = global_position - unit.global_position
		var distance = to_unit.length()
		if distance > 0:
			separation_vector += to_unit.normalized() * (1.0 / distance)
	
	return separation_vector.normalized() * separation_force

func check_arrival():
	if global_position.distance_to(target_position) < 15:
		moving = false
		velocity = Vector2.ZERO
		if target_resource and target_resource.has_method("start_harvest"):
			target_resource.start_harvest(self)

func check_collisions():
	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var collider = collision.get_collider()
		if collider.is_in_group("resources"):  # ✅ ya no solo "trees"
			moving = false
			velocity = Vector2.ZERO
			if collider.has_method("start_harvest"):
				collider.start_harvest(self)

func _on_body_entered(body: Node):
	if body != self and body.is_in_group("units"):
		nearby_units.append(body)

func _on_body_exited(body: Node):
	if body in nearby_units:
		nearby_units.erase(body)

func handle_attack():
	if !attack_target or !is_instance_valid(attack_target):
		stop_attacking()
		return
	
	# Rotar hacia el objetivo
	look_at(attack_target.global_position)
	
	if global_position.distance_to(attack_target.global_position) > attack_range:
		move_to(attack_target.global_position)
	elif can_attack:
		shoot_projectile()
		can_attack = false
		$AttackCooldown.start(attack_cooldown)

func shoot_projectile():
	if !attack_target or !is_instance_valid(attack_target):
		return
	
	var projectile = preload("res://Scenes/projectile.tscn").instantiate()
	projectile.init(attack_target, attack_damage)
	# Añadir al mundo con parámetros correctos
	get_parent().get_parent().add_child(projectile)  # Ajusta según tu estructura
	projectile.global_position = global_position
	projectile.rotation = (attack_target.global_position - global_position).angle()

func stop_attacking():
	is_attacking = false
	attack_target = null
	moving = false

func _on_attack_cooldown_timeout():
	can_attack = true

func attack(target: Node):
	if !target.is_in_group("enemies"):
		return
	
	attack_target = target
	is_attacking = true
	moving = false
	# Forzar actualización inmediata
	_physics_process(0)
