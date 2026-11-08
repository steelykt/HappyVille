extends Control
# Корень farm_screen.tscn (просто Control + этот скрипт). Всё остальное строится кодом.

const ICON := "res://assets/ui/icons/icon_%s.png"
const COLS := 7
const ROWS := ["CCCCCCC", "CCCCCCC", "CC333CC", "C4I.L8C", "C4B..8C", "C5PIL7C", "CC222CC", "CCCCCCC", "CCCCCCC"]
const ITEMS := {
	"L": {"icon": "log", "name": "Бревно", "desc": "Два таких дадут кучу", "price": 1},
	"P": {"icon": "pile", "name": "Куча брёвен (ур. 2)", "desc": "Стопка, готовая к делу", "price": 3},
	"B": {"icon": "plank", "name": "Доска", "desc": "Ровная и гладкая", "price": 2},
	"I": {"icon": "ice", "name": "Глыба льда", "desc": "Холодная, как зимнее утро", "price": 4},
}

var grid: Array = []
var cells: Array = []
var cache := {}
var selected := -1
var order_card: PanelContainer
var order_labels: Array = []
var info_icon: TextureRect
var info_name: Label
var info_desc: Label
var sell_btn: Button


func _ready() -> void:
	for r in ROWS:
		for ch in r:
			grid.append(ch)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 20)
	add_child(root)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(_build_order())
	root.add_child(_build_board())
	root.add_child(_build_info())
	_refresh()


func _tex(icon_name: String) -> Texture2D:
	if not cache.has(icon_name):
		cache[icon_name] = load(ICON % icon_name)
	return cache[icon_name]


func _icon(icon_name: String, px: float) -> TextureRect:
	var t := TextureRect.new()
	t.texture = _tex(icon_name)
	t.custom_minimum_size = Vector2(px, px)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _set_bg(btn: Button, color: Color) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(22)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(state, s)


func _build_order() -> Control:
	order_card = PanelContainer.new()
	order_card.theme_type_variation = "OrderPanel"
	order_card.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	order_card.add_child(row)
	for kind in ["log", "pile"]:
		row.add_child(_icon(kind, 100))
		var l := Label.new()
		row.add_child(l)
		order_labels.append(l)
	return order_card


func _build_board() -> Control:
	var ratio := AspectRatioContainer.new()
	ratio.ratio = float(COLS) / float(ROWS.size())
	ratio.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel := PanelContainer.new()
	panel.theme_type_variation = "PeachPanel"
	ratio.add_child(panel)
	var board := GridContainer.new()
	board.columns = COLS
	board.add_theme_constant_override("h_separation", 8)
	board.add_theme_constant_override("v_separation", 8)
	panel.add_child(board)
	for i in grid.size():
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(36, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_cell_pressed.bind(i))
		var tex := TextureRect.new()
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		btn.add_child(tex)
		tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		tex.offset_left = 6
		tex.offset_top = 6
		tex.offset_right = -6
		tex.offset_bottom = -6
		var lbl := Label.new()
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 36)
		lbl.add_theme_color_override("font_color", Color(0.3, 0.25, 0.28, 0.6))
		btn.add_child(lbl)
		lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		board.add_child(btn)
		cells.append({"btn": btn, "tex": tex, "lbl": lbl})
	return ratio


func _build_info() -> Control:
	var panel := PanelContainer.new()
	panel.theme_type_variation = "PeachPanel"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)
	info_icon = _icon("log", 100)
	row.add_child(info_icon)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_name = Label.new()
	info_desc = Label.new()
	info_desc.theme_type_variation = "LabelSoft"
	info_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texts.add_child(info_name)
	texts.add_child(info_desc)
	row.add_child(texts)
	var spawn := Button.new()
	spawn.text = "+ Бревно"
	spawn.theme_type_variation = "GreenButton"
	spawn.custom_minimum_size = Vector2(190, 100)
	spawn.pressed.connect(_on_spawn)
	row.add_child(spawn)
	sell_btn = Button.new()
	sell_btn.text = "Продать"
	sell_btn.theme_type_variation = "BlueButton"
	sell_btn.custom_minimum_size = Vector2(190, 100)
	sell_btn.pressed.connect(_on_sell)
	row.add_child(sell_btn)
	return panel


func _refresh() -> void:
	for i in grid.size():
		var k: String = grid[i]
		var c: Dictionary = cells[i]
		c.lbl.visible = false
		if k == "C":
			_set_bg(c.btn, Color(0.45, 0.33, 0.38, 0.35))
			c.tex.texture = _tex("crate")
		elif k == ".":
			_set_bg(c.btn, Color("ffe7d8"))
			c.tex.texture = null
		elif ITEMS.has(k):
			_set_bg(c.btn, Color("92e86f") if i == selected else Color("ffe7d8"))
			c.tex.texture = _tex(ITEMS[k].icon)
		else:
			_set_bg(c.btn, Color(0.45, 0.33, 0.38, 0.35))
			c.tex.texture = _tex("starlock")
			c.lbl.text = k
			c.lbl.visible = true
	var have := [grid.count("L"), grid.count("P")]
	order_labels[0].text = "%d/1" % have[0]
	order_labels[1].text = "%d/1" % have[1]
	order_card.modulate = Color(0.85, 1.0, 0.85) if have[0] > 0 and have[1] > 0 else Color.WHITE
	var sk: String = grid[selected] if selected >= 0 else ""
	if ITEMS.has(sk):
		info_icon.visible = true
		info_icon.texture = _tex(ITEMS[sk].icon)
		info_name.text = ITEMS[sk].name
		info_desc.text = ITEMS[sk].desc
		sell_btn.disabled = false
	else:
		info_icon.visible = false
		info_name.text = "Выбери предмет"
		info_desc.text = "Нажми на него"
		sell_btn.disabled = true


func _on_cell_pressed(i: int) -> void:
	var k: String = grid[i]
	if k == "." and selected >= 0:
		grid[i] = grid[selected]
		grid[selected] = "."
		selected = i
	elif ITEMS.has(k):
		if selected >= 0 and selected != i and grid[selected] == "L" and k == "L":
			grid[i] = "P"
			grid[selected] = "."
		selected = i
	else:
		return
	_refresh()


func _on_spawn() -> void:
	var idx: int = grid.find(".")
	if idx == -1 or not GameState.spend("energy", 1):
		return
	grid[idx] = "L"
	_refresh()


func _on_sell() -> void:
	if selected < 0 or not ITEMS.has(grid[selected]):
		return
	GameState.gold += int(ITEMS[grid[selected]].price)
	grid[selected] = "."
	selected = -1
	_refresh()
