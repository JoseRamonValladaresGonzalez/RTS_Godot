# Global.gd
extends Node

# Recursos
static var wood = 200
static var stone = 200
static var gold = 200
static var food = 200

# Costos de edificios (ahora es un diccionario normal)
static var building_costs = {
	"house": {"wood": 100, "stone": 50},
	"farm": {"wood": 50, "food": 30},
	"turret": {"wood": 150, "stone": 200}
}

# Verificar si se pueden costear los recursos (versión estática corregida)
static func can_afford(building_type: String) -> bool:
	var costs = building_costs.get(building_type, {})
	for resource in costs:
		# Accedemos directamente a las variables estáticas
		match resource:
			"wood":
				if wood < costs[resource]: return false
			"stone":
				if stone < costs[resource]: return false
			"gold":
				if gold < costs[resource]: return false
			"food":
				if food < costs[resource]: return false
	return true

# Descontar recursos (versión estática corregida)
static func deduct_resources(building_type: String):
	var costs = building_costs.get(building_type, {})
	for resource in costs:
		# Modificamos directamente las variables estáticas
		match resource:
			"wood":
				wood -= costs[resource]
			"stone":
				stone -= costs[resource]
			"gold":
				gold -= costs[resource]
			"food":
				food -= costs[resource]



static var unit_costs = {
	"villager": {"food": 20, "wood": 10}
}

static func can_afford_unit(unit_type: String) -> bool:
	var costs = unit_costs.get(unit_type, {})
	for resource in costs:
		match resource:
			"wood": if wood < costs[resource]: return false
			"food": if food < costs[resource]: return false
			"stone": if stone < costs[resource]: return false
			"gold": if gold < costs[resource]: return false
	return true

static func deduct_unit_cost(unit_type: String):
	var costs = unit_costs.get(unit_type, {})
	for resource in costs:
		match resource:
			"wood": wood -= costs[resource]
			"food": food -= costs[resource]
			"stone": stone -= costs[resource]
			"gold": gold -= costs[resource]
