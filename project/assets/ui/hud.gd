extends Control
# Корень hud.tscn. Нужные узлы с Access as Unique Name: LevelLabel, EnergyLabel, GoldLabel, GemsLabel

@onready var level_label: Label = %LevelLabel
@onready var energy_label: Label = %EnergyLabel
@onready var gold_label: Label = %GoldLabel
@onready var gems_label: Label = %GemsLabel


func _ready() -> void:
	GameState.changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	level_label.text = str(GameState.level)
	_set_text(energy_label, "%d/%d" % [GameState.energy, GameState.MAX_ENERGY])
	_set_text(gold_label, str(GameState.gold))
	_set_text(gems_label, str(GameState.gems))


func _set_text(label: Label, text: String) -> void:
	if label.text == text:
		return
	var first := label.text.is_empty()
	label.text = text
	if first:
		return
	label.pivot_offset = label.size / 2.0
	var tw := create_tween()
	tw.tween_property(label, "scale", Vector2(1.2, 1.2), 0.08)
	tw.tween_property(label, "scale", Vector2.ONE, 0.12)
