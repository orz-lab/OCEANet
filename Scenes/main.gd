extends Node2D

var weight_1:float = 0
var graph_id = {}

var graph_template = preload("res://Scenes/Graph/Graph.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
	randomize()
	rng.randomize()
	
	for id in range(PlayerStats.fish_inventory.size()):
		var fish = PlayerStats.fish_inventory[id].duplicate()
		_fish_option.add_item(fish["name"], id)
		var graph = graph_template.instantiate()
		graph.name_fish = fish["name"]
		$Control/Graphs.add_child(graph)
		graph_id[id] = graph
		_fish_option.selected = 0
		_on_option_button_item_selected(0)
		
func _process(delta):
	_set_input()

func _on_price_change_timeout():
	for id in graph_id:
		var graph = graph_id[id]
		var delta_weight = PlayerStats.fish_inventory[id]["delta"]
		var delta_price = rng.randf_range(0,1 * (delta_weight / 100.0 + 1.0))
		if rng.randi_range(0,50) == 0:
			delta_price = rng.randf_range(0,25)
		
		#print(weight_1)
		#print(-100 + weight_1, " ", 100 - weight_1)
		if rng.randf_range(-100 - weight_1, 100 + weight_1) < 0:
			delta_price *= -1
		
		weight_1 += delta_price
		var current_price = graph_id[id].current_price
		current_price = max(0, current_price + delta_price)
		#print(id, " ", current_price)
		graph.add_point(current_price)


@onready var _fish_input = $Control/InputBox/FishInput/LineEdit
@onready var _money_input = $Control/InputBox/MoneyInput/LineEdit
@onready var _fish_option = $Control/PlayerStatsBox/OptionButton
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
