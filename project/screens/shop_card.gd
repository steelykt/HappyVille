extends PanelContainer
# Корень shop_card.tscn. Узлы с Unique Name: Icon (TextureRect), NameLabel, DescLabel, BuyButton

signal buy_pressed(item: Dictionary)

var item: Dictionary

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var buy_button: Button = %BuyButton


func setup(data: Dictionary) -> void:  # вызывать ПОСЛЕ add_child
	item = data
	icon.texture = load("res://assets/ui/icons/icon_%s.png" % data.icon)
	name_label.text = data.name
	desc_label.text = data.desc
	buy_button.icon = load("res://assets/ui/icons/icon_%s.png" % data.cur_icon)
	buy_button.text = str(data.price)
	buy_button.pressed.connect(func(): buy_pressed.emit(item))
	refresh()


func refresh() -> void:
	buy_button.disabled = not GameState.can_afford(item.currency, item.price)
