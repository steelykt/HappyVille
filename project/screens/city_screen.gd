extends Control
# Корень city_screen.tscn (просто Control + этот скрипт). Всё остальное строится кодом.

const ICON := "res://assets/ui/icons/icon_%s.png"
const BUILD_COST := 100
const PLOTS := [Vector2(0.30, 0.50), Vector2(0.72, 0.44)]  # доли ширины и высоты экрана
const QUESTS := [{"title": "Построить 2 здания", "need": 2}, {"title": "Накопить 2000 монет", "need": 2000}]

var built := 0
var bars: Array = []
var labels: Array = []


func _ready() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/ui/bg/bg_village.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.offset_top = -160
	_add_building("barn", Vector2(0.72, 0.2), 300)
	_add_building("city", Vector2(0.20, 0.30), 280)
	for pos in PLOTS:
		var btn := Button.new()
		btn.text = str(BUILD_COST)
		btn.icon = load(ICON % "hammer")
		btn.expand_icon = true
		btn.add_theme_constant_override("icon_max_width", 56)
		btn.theme_type_variation = "PurpleButton"
		add_child(btn)
		_place(btn, pos, Vector2(260, 100))
		btn.pressed.connect(_on_plot.bind(btn, pos))
	_build_quests()
	GameState.changed.connect(_refresh_quests)
	_refresh_quests()


func _place(n: Control, p: Vector2, s: Vector2) -> void:
	n.anchor_left = p.x
	n.anchor_right = p.x
	n.anchor_top = p.y
	n.anchor_bottom = p.y
	n.offset_left = -s.x / 2.0
	n.offset_right = s.x / 2.0
	n.offset_top = -s.y / 2.0
	n.offset_bottom = s.y / 2.0


func _add_building(kind: String, pos: Vector2, px: float) -> void:
	var t := TextureRect.new()
	t.texture = load(ICON % kind)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(t)
	_place(t, pos, Vector2(px, px))


func _build_quests() -> void:
	var panel := PanelContainer.new()
	panel.theme_type_variation = "PeachPanel"
	add_child(panel)
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	panel.offset_left = 20
	panel.offset_right = -20
	panel.offset_bottom = -20
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	panel.add_child(v)
	var title := Label.new()
	title.text = "Квесты"
	v.add_child(title)
	for q in QUESTS:
		var l := Label.new()
		l.theme_type_variation = "SoftLabel"
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(0, 28)
		v.add_child(l)
		v.add_child(bar)
		labels.append(l)
		bars.append(bar)


func _refresh_quests() -> void:
	var values := [built, GameState.gold]
	for i in QUESTS.size():
		var need: int = QUESTS[i].need
		var have: int = mini(int(values[i]), need)
		bars[i].max_value = need
		bars[i].value = have
		labels[i].text = "%s   %d/%d" % [QUESTS[i].title, have, need]


func _on_plot(btn: Button, pos: Vector2) -> void:
	if not GameState.spend("gold", BUILD_COST):
		return
	btn.queue_free()
	_add_building("city", pos, 260)
	built += 1
	_refresh_quests()
