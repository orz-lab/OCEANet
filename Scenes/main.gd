extends Node2D

var graph_id = {}

var graph_template = preload("res://Scenes/Graph/Graph.tscn")
var rng = RandomNumberGenerator.new()

var fishes_api = []
var api2id = {}

func _ready():
	Network._on_update_price.connect(_on_update_price)
	
	randomize()
	rng.randomize()
	
	for id in range(PlayerStats.fish_inventory.size()):
		var fish = PlayerStats.fish_inventory[id].duplicate()
		_fish_option.add_item(fish["name"], id)
		var graph = graph_template.instantiate()
		graph.fish_id = id
		graph.change_price.connect(on_change_price)
		$Control/Graphs.add_child(graph)
		if fish.has("api"):
			fishes_api.append(fish["api"])
			api2id[fish["api"]] = id
		graph_id[id] = graph
		_fish_option.selected = 0
		_on_option_button_item_selected(0)

		
func _process(delta):
	_set_input()
	
	if Network.is_connected:
		$ConnectStat.text = "Online Mode"
		$ConnectStat.set("theme_override_colors/font_color", Color.GREEN)
	else:
		$ConnectStat.text = "Offine Mode"
		$ConnectStat.set("theme_override_colors/font_color", Color.RED)

@onready var _fish_input = $Control/InputBox/FishInput/LineEdit
@onready var _money_input = $Control/InputBox/MoneyInput/LineEdit
@onready var _fish_option = $Control/InputBox/OptionButton
var money_input:float = 0.0
var fish_input:float = 0.0
var last_change: last_change_enum = last_change_enum.MONEY

enum last_change_enum{
	MONEY,
	FISH
}

func _set_input():
	match last_change:
		last_change_enum.MONEY:
			fish_input = money_input / graph_id[_fish_option.selected].current_price
			_fish_input.text = str(fish_input)
		last_change_enum.FISH:
			money_input = fish_input * graph_id[_fish_option.selected].current_price
			_money_input.text = str(money_input)
	
	$Control/PlayerStatsBox/TotalMoney/Cash.text = str("%.2f" % PlayerStats.total_money)
	$Control/PlayerStatsBox/TotalFish/Fish.text = str("%.2f" % PlayerStats.fish_inventory[_fish_option.selected]["amount"])

func _on_money_input_changed(new_text):
	if not new_text.is_valid_float():
		return

	money_input = float(new_text)
	last_change = last_change_enum.MONEY

func _on_fish_input_changed(new_text):
	if not new_text.is_valid_float():
		return
	
	fish_input = float(new_text)
	last_change = last_change_enum.FISH

func _on_sell_pressed():
	var fish_amount = PlayerStats.fish_inventory[_fish_option.selected]["amount"]
	if fish_amount - fish_input >= 0:
		fish_amount -= fish_input
		PlayerStats.total_money += money_input
	
	PlayerStats.fish_inventory[_fish_option.selected]["amount"] = fish_amount


func _on_buy_pressed():
	if PlayerStats.total_money - money_input >= 0:
		PlayerStats.total_money -= money_input
		PlayerStats.fish_inventory[_fish_option.selected]["amount"] += fish_input


func _on_option_button_item_selected(index):
	for id in graph_id:
		graph_id[id].visible = (id == index)


func _on_line_edit_gui_input(event):
	pass # Replace with function body.


func _on_money_mouse_input(event):
	if event is InputEventMouseButton and event.pressed:
		last_change = last_change_enum.MONEY



func _on_fish_mouse_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		last_change = last_change_enum.FISH

func on_change_price(price):
	if price <= 0.01:
		$Control/InputBox/Buy.disabled = true
		$Control/InputBox/Buy.text = "Cá đã phá sản"
		$Control/InputBox/Buy.add_theme_font_size_override("font_size", 20)
	else:
		$Control/InputBox/Buy.disabled = false
		$Control/InputBox/Buy.text = "BUY"
		$Control/InputBox/Buy.add_theme_font_size_override("font_size", 75)

func _on_update_price_timeout():
	if Network.is_connected:
		Network.ask_price(fishes_api)
	
func _on_update_price(list_price):
	for fish in list_price:
		for fish_name in fish:
			graph_id[api2id[fish_name]]._on_update_price(fish[fish_name])
