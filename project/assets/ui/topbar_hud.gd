extends HBoxContainer
# Повесь этот скрипт на узел TopBar (HBoxContainer) в happy_ville_ui.tscn.
# Пути рассчитаны на твоё дерево: EnergyLayout/EnergyIconValue/EnergyValue и т.д.

@onready var energy_label: Label = $EnergyLayout/EnergyIconValue/EnergyValue
@onready var gold_label: Label = $GoldLayout/GoldIconValue/GoldValue
@onready var gems_label: Label = $GemsLayout/GemsIconValue/GemsValue


func _ready() -> void:
	GameState.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	_set_text(energy_label, "%d/%d" % [GameState.energy, GameState.MAX_ENERGY])
	_set_text(gold_label, str(GameState.gold))
	_set_text(gems_label, str(GameState.gems))


func _set_text(label: Label, text: String) -> void:
	if label.text == text:
		return
	var animate := label.text != "" and label.is_inside_tree()
	label.text = text
	if not animate:
		return
	label.pivot_offset = label.size / 2.0
	var tw := create_tween()
	tw.tween_property(label, "scale", Vector2(1.2, 1.2), 0.08)
	tw.tween_property(label, "scale", Vector2.ONE, 0.12)
