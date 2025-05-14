extends CharacterBody2D

@export var selected: bool = false:
	set(value):
		selected = value
		box.visible = selected

@export var speed: float = 200.0
@export var separation_force: float = 300.0
@export var separation_radius: float = 60.0

@onready var box: Panel = $Box
@onready var separation_area: Area2D = $SeparationArea
signal moving_started
var target_position: Vector2 = Vector2.ZERO
var moving: bool = false
var target_resource: Node = null

var nearby_units: Array = []

func _ready():
	box.visible = selected
	setup_separation_area()

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
