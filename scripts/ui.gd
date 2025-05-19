extends CanvasLayer

@onready var wood: Label = $VBoxContainer/wood

@onready var stone: Label = $VBoxContainer/stone

@onready var gold: Label = $VBoxContainer/gold
@onready var tower_button: Button = $VBoxContainer/TowerButton

@onready var food: Label = $VBoxContainer/food
@onready var build_button: Button = $VBoxContainer/build_button
var building_selected = false
var building_type = null 
var building_mode_active: bool = false 

func _process(delta: float) -> void:
	wood.text = "Wood = " + str(Global.wood)
	stone.text ="Stone = " + str(Global.stone)
	gold.text ="Gold = " + str(Global.gold)
	food.text ="Food = " + str(Global.food)


var building_costs = {
	"house": {"wood": 100, "stone": 50},
	"farm": {"wood": 50, "food": 30},
	"turret": {"wood": 150, "stone": 200}
}

signal building_mode_changed(enabled: bool, type: String)

func _on_build_button_pressed() -> void:
	if building_mode_active:
		# Si ya está en modo construcción, cancelar
		building_mode_active = false
		building_type = null
		building_mode_changed.emit(false, "")
	else:
		if can_afford("house"):
			building_mode_active = true
			building_type = "house"
			building_mode_changed.emit(true, "house")
		else:
			print("No tienes suficientes recursos para una casa!")

func can_afford(building: String) -> bool:
	var costs = building_costs.get(building, {})
	for resource in costs:
		if Global.get(resource) < costs[resource]:
			return false
	return true


func _on_tower_button_pressed() -> void:
	if building_mode_active:
		# Si ya está en modo construcción, cancelar
		building_mode_active = false
		building_type = null
		building_mode_changed.emit(false, "")
	else:
		if can_afford("turret"):
			building_mode_active = true
			building_type = "turret"
			building_mode_changed.emit(true, "turret")
		else:
			print("No tienes suficientes recursos para una torreta!")
