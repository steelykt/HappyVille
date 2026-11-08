extends CanvasLayer
# Корень main.tscn. Узлы с Unique Name: ScreenHost, ShopTab, FarmTab, CityTab

const SCREENS := {
	"shop": preload("res://screens/shop_screen.tscn"),
	"farm": preload("res://screens/farm_screen.tscn"),
	"city": preload("res://screens/city_screen.tscn"),
}

@onready var host: Control = %ScreenHost
@onready var tabs := {"shop": %ShopTab, "farm": %FarmTab, "city": %CityTab}
var current: Control


func _ready() -> void:
	var group := ButtonGroup.new()
	for key in tabs:
		var b: Button = tabs[key]
		b.toggle_mode = true
		b.button_group = group
		b.pressed.connect(show_screen.bind(key))
	tabs["farm"].button_pressed = true
	show_screen("farm")

func _apply_safe_area() -> void:
	var safe := DisplayServer.get_display_safe_area()
	var win := DisplayServer.window_get_size()
	if win.y == 0:
		return
	var k := get_viewport().get_visible_rect().size.y / float(win.y)
	var top := int(safe.position.y * k)
	$MainLayout.add_theme_constant_override("margin_top", 40 + top)

func show_screen(key: String) -> void:
	if current and current.get_meta("key", "") == key:
		return
	if current:
		current.queue_free()
	current = SCREENS[key].instantiate()
	current.set_meta("key", key)
	host.add_child(current)
	current.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current.modulate.a = 0.0
	create_tween().tween_property(current, "modulate:a", 1.0, 0.18)
