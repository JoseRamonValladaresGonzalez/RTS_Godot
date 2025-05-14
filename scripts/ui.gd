extends CanvasLayer

@onready var wood: Label = $VBoxContainer/wood

@onready var stone: Label = $VBoxContainer/stone

@onready var gold: Label = $VBoxContainer/gold

@onready var food: Label = $VBoxContainer/food
@onready var build_button: Button = $VBoxContainer/build_button
var building_selected = false
var building_type = null 


func _process(delta: float) -> void:
	wood.text = "Wood = " + str(Global.wood)
	stone.text ="Stone = " + str(Global.stone)
	gold.text ="Gold = " + str(Global.gold)
	food.text ="Food = " + str(Global.food)


var building_costs = {
	"house": {"wood": 100, "stone": 50},
	"farm": {"wood": 50, "food": 30}
}

signal building_mode_changed(enabled: bool, type: String)

func _on_build_button_pressed() -> void:
	if Global.can_afford("house"):  # Ahora usa el método estático corregido
		building_selected = true
		building_type = "house"
		building_mode_changed.emit(true, "house")
	else:
		print("No tienes suficientes recursos!")

func can_afford(building: String) -> bool:
	var costs = building_costs.get(building, {})
	for resource in costs:
		if Global.get(resource) < costs[resource]:
			return false
	return true
