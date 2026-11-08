extends Control
# Корень shop_screen.tscn. Узел с Unique Name: CardGrid (GridContainer, 2 колонки)

const CARD := preload("res://screens/shop_card.tscn")
const ITEMS := [
	{"id": "baker", "name": "Пекарь", "desc": "Печёт хлеб", "icon": "bread", "currency": "gold", "cur_icon": "coin", "price": 500},
	{"id": "farmer", "name": "Фермер", "desc": "Растит пшеницу", "icon": "wheat", "currency": "gold", "cur_icon": "coin", "price": 800},
	{"id": "builder", "name": "Строитель", "desc": "Даёт доски", "icon": "hammer", "currency": "gold", "cur_icon": "coin", "price": 1200},
	{"id": "energy", "name": "Энергия", "desc": "Полный заряд", "icon": "bolt", "currency": "gems", "cur_icon": "gem", "price": 10},
	{"id": "garden", "name": "Сад", "desc": "Яблоки и деревья", "icon": "tree", "currency": "gold", "cur_icon": "coin", "price": 2000},
	{"id": "chest", "name": "Сундук", "desc": "Редкие находки", "icon": "crate", "currency": "gems", "cur_icon": "gem", "price": 25},
]

@onready var grid: GridContainer = %CardGrid
var cards: Array = []


func _ready() -> void:
	for d in ITEMS:
		var card = CARD.instantiate()
		grid.add_child(card)
		card.setup(d)
		card.buy_pressed.connect(_on_buy)
		cards.append(card)
	GameState.changed.connect(_refresh_cards)


func _on_buy(d: Dictionary) -> void:
	if GameState.spend(d.currency, d.price):
		GameState.give(d.id)
		if d.id == "energy":
			GameState.energy += 50


func _refresh_cards() -> void:
	for c in cards:
		c.refresh()
