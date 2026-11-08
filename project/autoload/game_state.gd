extends Node
# Автозагрузка (Autoload) с именем GameState. Единственное место, где живут ресурсы игрока.

signal changed

const MAX_ENERGY := 100

var level := 1
var energy := 71:
	set(v):
		energy = clampi(v, 0, MAX_ENERGY)
		changed.emit()
var gold := 1540:
	set(v):
		gold = maxi(v, 0)
		changed.emit()
var gems := 45:
	set(v):
		gems = maxi(v, 0)
		changed.emit()
var owned := {}  # id покупки -> сколько куплено


func can_afford(currency: String, amount: int) -> bool:
	return int(get(currency)) >= amount


func spend(currency: String, amount: int) -> bool:
	if not can_afford(currency, amount):
		return false
	set(currency, int(get(currency)) - amount)
	return true


func give(id: String) -> void:
	owned[id] = int(owned.get(id, 0)) + 1
	changed.emit()
