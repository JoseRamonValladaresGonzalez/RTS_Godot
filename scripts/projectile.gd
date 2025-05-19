extends Area2D

var speed: float = 400.0
var target: Node
var damage: int = 1

func init(target_node: Node, dmg: int):
	target = target_node
	damage = dmg

func _physics_process(delta):
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
	else:
		queue_free()

func _on_body_entered(body):
	print("Impacto detectado con: ", body.name)
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()



func _on_life_timer_timeout() -> void:
	queue_free()
